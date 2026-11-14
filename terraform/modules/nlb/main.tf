terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_eip" "this" {
  domain = "vpc"

  tags = {
    Name = var.eip_name
  }
}

resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "network"
  internal           = var.internal
  security_groups    = var.security_group_ids

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  subnet_mapping {
    subnet_id     = var.subnet_id
    allocation_id = aws_eip.this.id
  }
}

# Target 등록은 Terraform으로 관리하지 않는다.
resource "aws_lb_target_group" "this" {
  name        = var.target_group.name
  target_type = var.target_group.target_type
  protocol    = var.target_group.protocol
  port        = var.target_group.port
  vpc_id      = var.vpc_id

  health_check {
    protocol = var.target_group.health_check.protocol
    path     = var.target_group.health_check.path
    matcher  = var.target_group.health_check.matcher
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener.port
  protocol          = var.listener.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = {
    Name = var.listener.name
  }
}
