terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_route53_zone" "this" {
  name = var.zone.name

  tags = {
    Name = var.zone.tag_name
  }
}

# DNS 검증 CNAME은 수동 등록하므로 검증 레코드와 aws_acm_certificate_validation은 생성하지 않는다.
resource "aws_acm_certificate" "this" {
  domain_name               = var.certificate.domain_name
  subject_alternative_names = var.certificate.subject_alternative_names
  validation_method         = var.certificate.validation_method

  tags = {
    Name = var.certificate.name
  }
}
