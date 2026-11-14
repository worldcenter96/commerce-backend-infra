terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# aws_security_group은 기본 allow-all egress를 제거하므로, egress는 egress_rules에 정의된 규칙만 생성된다.
resource "aws_security_group" "this" {
  name   = var.name
  vpc_id = var.vpc_id

  tags = {
    Name = var.name
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.ingress_rules

  security_group_id            = aws_security_group.this.id
  ip_protocol                  = each.value.ip_protocol
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.referenced_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.egress_rules

  security_group_id            = aws_security_group.this.id
  ip_protocol                  = each.value.ip_protocol
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.referenced_security_group_id
}
