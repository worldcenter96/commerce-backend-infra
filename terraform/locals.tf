# infrastructure-spec.md v1.0 기준 값
locals {
  # §2 Common
  region = "ap-northeast-2"

  # naming_convention: {project}-{environment}-{resource}-{role}
  name_prefix = "commerce-prod"

  default_tags = {
    project     = "commerce"
    environment = "prod"
    managedBy   = "terraform"
  }

  # §4.1 Subnet
  subnets = {
    public-bastion = { cidr_block = "192.168.0.0/27", availability_zone = "ap-northeast-2a", map_public_ip_on_launch = true }
    public-nlb     = { cidr_block = "192.168.0.128/27", availability_zone = "ap-northeast-2a" }
    private-alb-a  = { cidr_block = "192.168.0.64/27", availability_zone = "ap-northeast-2a" }
    private-alb-c  = { cidr_block = "192.168.0.224/27", availability_zone = "ap-northeast-2c" }
    private-app    = { cidr_block = "192.168.0.32/27", availability_zone = "ap-northeast-2a" }
    private-redis  = { cidr_block = "192.168.0.160/27", availability_zone = "ap-northeast-2a" }
    private-rds-a  = { cidr_block = "192.168.0.192/27", availability_zone = "ap-northeast-2a" }
    private-rds-c  = { cidr_block = "192.168.0.96/27", availability_zone = "ap-northeast-2c" }
  }

  # §4.5 EC2 (OS 공통 정보: fixed_ami_id)
  ami_id = "ami-05b829d75c9f9183e"

  # §4.5 EC2별 상세 설정. sg는 Security Group 모듈 키
  instances = {
    admin   = { subnet = "private-app", sg = "app", instance_type = "t3.medium", public_ip = false, key_name = "commerce-prod-app-key", root_volume_size = 10 }
    b2b     = { subnet = "private-app", sg = "app", instance_type = "t3.medium", public_ip = false, key_name = "commerce-prod-app-key", root_volume_size = 10 }
    b2c     = { subnet = "private-app", sg = "app", instance_type = "t3.medium", public_ip = false, key_name = "commerce-prod-app-key", root_volume_size = 10 }
    log     = { subnet = "private-app", sg = "loki", instance_type = "t3.large", public_ip = false, key_name = "commerce-prod-log-key", root_volume_size = 20 }
    bastion = { subnet = "public-bastion", sg = "bastion", instance_type = "t3.medium", public_ip = true, key_name = "commerce-prod-bastion-key", root_volume_size = 10 }
  }

  # Security Group 모듈 출력 모음 (EC2 for_each에서 키로 참조)
  security_group_ids = {
    app     = module.sg_app.id
    loki    = module.sg_loki.id
    bastion = module.sg_bastion.id
  }
}
