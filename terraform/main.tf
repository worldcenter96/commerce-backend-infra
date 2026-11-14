# Root Module: Child Module 호출과 모듈 간 연결
# 기준: docs/infrastructure-spec.md v1.0
#
# Terraform 관리 제외(managed_by: manual):
#   ALB HTTPS Listener / Listener Rule / Target Group, NLB Target Group에 ALB 등록,
#   Route 53 Alias 레코드, registrar NS 위임, ACM DNS 검증 CNAME, Key Pair(이름만 참조),
#   CodeDeploy Deployment Group, IAM 전체

# ---------------------------------------------------------------------------
# §4.1 Network
# ---------------------------------------------------------------------------
module "network" {
  source = "./modules/network"

  vpc_name       = "${local.name_prefix}-vpc-main"
  vpc_cidr_block = "192.168.0.0/24"

  subnets = {
    for key, subnet in local.subnets : key => merge(subnet, {
      name = "${local.name_prefix}-subnet-${key}"
    })
  }

  internet_gateway_name = "${local.name_prefix}-igw-main"

  nat_gateway = {
    name       = "${local.name_prefix}-nat-main"
    eip_name   = "${local.name_prefix}-eip-nat"
    subnet_key = "public-bastion"
  }

  public_route_table = {
    name        = "${local.name_prefix}-rt-public"
    subnet_keys = ["public-bastion", "public-nlb"]
  }

  nat_route_table = {
    name        = "${local.name_prefix}-rt-private-app"
    subnet_keys = ["private-app"]
  }

  local_route_table = {
    name        = "${local.name_prefix}-rt-private-local"
    subnet_keys = ["private-alb-a", "private-alb-c", "private-redis", "private-rds-a", "private-rds-c"]
  }
}

# ---------------------------------------------------------------------------
# §4.2 Security Group (D-046: egress는 명세에 정의된 규칙만)
# ---------------------------------------------------------------------------
module "sg_nlb" {
  source = "./modules/security_group"

  name   = "${local.name_prefix}-sg-nlb"
  vpc_id = module.network.vpc_id

  ingress_rules = {
    https_from_internet = { ip_protocol = "tcp", from_port = 443, to_port = 443, cidr_ipv4 = "0.0.0.0/0" }
  }
  egress_rules = {
    https_to_alb = { ip_protocol = "tcp", from_port = 443, to_port = 443, referenced_security_group_id = module.sg_alb.id }
  }
}

module "sg_alb" {
  source = "./modules/security_group"

  name   = "${local.name_prefix}-sg-alb"
  vpc_id = module.network.vpc_id

  ingress_rules = {
    https_from_nlb = { ip_protocol = "tcp", from_port = 443, to_port = 443, referenced_security_group_id = module.sg_nlb.id }
  }
  egress_rules = {
    http_to_app = { ip_protocol = "tcp", from_port = 8080, to_port = 8080, referenced_security_group_id = module.sg_app.id }
  }
}

module "sg_app" {
  source = "./modules/security_group"

  name   = "${local.name_prefix}-sg-app"
  vpc_id = module.network.vpc_id

  ingress_rules = {
    http_from_alb    = { ip_protocol = "tcp", from_port = 8080, to_port = 8080, referenced_security_group_id = module.sg_alb.id }
    ssh_from_bastion = { ip_protocol = "tcp", from_port = 22, to_port = 22, referenced_security_group_id = module.sg_bastion.id }
  }
  egress_rules = {
    all = { ip_protocol = "-1", cidr_ipv4 = "0.0.0.0/0" }
  }
}

module "sg_loki" {
  source = "./modules/security_group"

  name   = "${local.name_prefix}-sg-loki"
  vpc_id = module.network.vpc_id

  ingress_rules = {
    loki_from_app        = { ip_protocol = "tcp", from_port = 3100, to_port = 3100, referenced_security_group_id = module.sg_app.id }
    ssh_from_bastion     = { ip_protocol = "tcp", from_port = 22, to_port = 22, referenced_security_group_id = module.sg_bastion.id }
    grafana_from_bastion = { ip_protocol = "tcp", from_port = 3000, to_port = 3000, referenced_security_group_id = module.sg_bastion.id }
  }
  egress_rules = {
    all = { ip_protocol = "-1", cidr_ipv4 = "0.0.0.0/0" }
  }
}

module "sg_bastion" {
  source = "./modules/security_group"

  name   = "${local.name_prefix}-sg-bastion"
  vpc_id = module.network.vpc_id

  ingress_rules = {
    ssh_from_admin = { ip_protocol = "tcp", from_port = 22, to_port = 22, cidr_ipv4 = "119.192.127.156/32" }
  }
  egress_rules = {
    all = { ip_protocol = "-1", cidr_ipv4 = "0.0.0.0/0" }
  }
}

module "sg_rds" {
  source = "./modules/security_group"

  name   = "${local.name_prefix}-sg-rds"
  vpc_id = module.network.vpc_id

  ingress_rules = {
    mysql_from_app     = { ip_protocol = "tcp", from_port = 3306, to_port = 3306, referenced_security_group_id = module.sg_app.id }
    mysql_from_bastion = { ip_protocol = "tcp", from_port = 3306, to_port = 3306, referenced_security_group_id = module.sg_bastion.id }
  }
}

module "sg_redis" {
  source = "./modules/security_group"

  name   = "${local.name_prefix}-sg-redis"
  vpc_id = module.network.vpc_id

  ingress_rules = {
    redis_from_app     = { ip_protocol = "tcp", from_port = 6379, to_port = 6379, referenced_security_group_id = module.sg_app.id }
    redis_from_bastion = { ip_protocol = "tcp", from_port = 6379, to_port = 6379, referenced_security_group_id = module.sg_bastion.id }
  }
}

# ---------------------------------------------------------------------------
# §4.3 Load Balancing
# ---------------------------------------------------------------------------
module "nlb" {
  source = "./modules/nlb"

  name                             = "${local.name_prefix}-nlb-public"
  eip_name                         = "${local.name_prefix}-eip-nlb"
  internal                         = false
  subnet_id                        = module.network.subnet_ids["public-nlb"]
  security_group_ids               = [module.sg_nlb.id]
  enable_cross_zone_load_balancing = false
  vpc_id                           = module.network.vpc_id

  target_group = {
    name        = "${local.name_prefix}-tg-nlb-alb"
    target_type = "alb"
    protocol    = "TCP"
    port        = 443
    health_check = {
      protocol = "HTTPS"
      path     = "/healthz"
      matcher  = "200"
    }
  }

  listener = {
    name     = "${local.name_prefix}-listener-nlb-443"
    port     = 443
    protocol = "TCP"
  }
}

module "alb" {
  source = "./modules/alb"

  name     = "${local.name_prefix}-alb-internal"
  internal = true
  subnet_ids = [
    module.network.subnet_ids["private-alb-a"],
    module.network.subnet_ids["private-alb-c"],
  ]
  security_group_ids = [module.sg_alb.id]
}

# ---------------------------------------------------------------------------
# §4.4 DNS · Certificate
# ---------------------------------------------------------------------------
module "dns_certificate" {
  source = "./modules/dns_certificate"

  zone = {
    name     = "imcommerce.shop"
    tag_name = "${local.name_prefix}-zone-imcommerce"
  }

  certificate = {
    name                      = "${local.name_prefix}-acm-imcommerce"
    domain_name               = "imcommerce.shop"
    subject_alternative_names = ["*.imcommerce.shop"]
    validation_method         = "DNS"
  }
}

# ---------------------------------------------------------------------------
# §4.5 Compute
# ---------------------------------------------------------------------------
module "ec2" {
  source   = "./modules/ec2_instance"
  for_each = local.instances

  name                        = "${local.name_prefix}-ec2-${each.key}"
  ami_id                      = local.ami_id
  instance_type               = each.value.instance_type
  subnet_id                   = module.network.subnet_ids[each.value.subnet]
  security_group_ids          = [local.security_group_ids[each.value.sg]]
  associate_public_ip_address = each.value.public_ip
  key_name                    = each.value.key_name
  metadata_http_tokens        = "required"
  root_volume_size            = each.value.root_volume_size
  root_volume_encrypted       = true
}

# ---------------------------------------------------------------------------
# §4.6 Database
# ---------------------------------------------------------------------------
module "rds" {
  source = "./modules/rds"

  subnet_group_name = "${local.name_prefix}-dbsubnet-rds"
  subnet_ids = [
    module.network.subnet_ids["private-rds-a"],
    module.network.subnet_ids["private-rds-c"],
  ]

  parameter_group = {
    name   = "${local.name_prefix}-dbparam-mysql80"
    family = "mysql8.0"
    parameters = [
      { name = "require_secure_transport", value = "1" },
    ]
  }

  identifier                  = "${local.name_prefix}-rds-mysql"
  engine                      = "mysql"
  engine_version              = "8.0"
  instance_class              = "db.t3.medium"
  allocated_storage           = 20
  storage_type                = "gp3"
  storage_encrypted           = true
  multi_az                    = false
  availability_zone           = "ap-northeast-2a"
  security_group_ids          = [module.sg_rds.id]
  port                        = 3306
  publicly_accessible         = false
  db_name                     = "commerce"
  username                    = "dbadmin"
  manage_master_user_password = true
  backup_retention_period     = 0
  skip_final_snapshot         = true
  deletion_protection         = false
}

# ---------------------------------------------------------------------------
# §4.7 Cache
# ---------------------------------------------------------------------------
module "elasticache" {
  source = "./modules/elasticache"

  subnet_group_name = "${local.name_prefix}-cachesubnet-redis"
  subnet_ids        = [module.network.subnet_ids["private-redis"]]

  replication_group_id       = "${local.name_prefix}-redis-main"
  description                = "Redis cache for commerce production"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = "cache.t4g.small"
  num_cache_clusters         = 1
  port                       = 6379
  security_group_ids         = [module.sg_redis.id]
  transit_encryption_enabled = true
  transit_encryption_mode    = "required"
  at_rest_encryption_enabled = true
}

# ---------------------------------------------------------------------------
# §4.8 CI/CD
# ---------------------------------------------------------------------------
module "cicd" {
  source = "./modules/cicd"

  artifact_bucket = {
    name              = "commerce-prod-codedeploy-artifacts"
    force_destroy     = true
    versioning_status = "Enabled"
    sse_algorithm     = "AES256"
    public_access_block = {
      block_public_acls       = false
      ignore_public_acls      = false
      block_public_policy     = false
      restrict_public_buckets = false
    }
  }

  codedeploy_app = {
    name             = "commerce-prod-codedeploy-cd"
    compute_platform = "Server"
  }
}
