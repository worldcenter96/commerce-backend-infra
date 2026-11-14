terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Listener, Listener Rule, Target Group은 Terraform으로 관리하지 않는다.
resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  internal           = var.internal
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids
}
