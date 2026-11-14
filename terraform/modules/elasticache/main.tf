terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_elasticache_subnet_group" "this" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_ids
}

# AUTH 미사용: auth_token을 설정하지 않는다.
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.replication_group_id
  description          = var.description

  engine             = var.engine
  engine_version     = var.engine_version
  node_type          = var.node_type
  num_cache_clusters = var.num_cache_clusters
  port               = var.port

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = var.security_group_ids

  transit_encryption_enabled = var.transit_encryption_enabled
  transit_encryption_mode    = var.transit_encryption_mode
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
}
