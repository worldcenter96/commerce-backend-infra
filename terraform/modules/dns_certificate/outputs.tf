output "zone_id" {
  description = "Hosted Zone ID"
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "registrar NS 위임에 사용할 Name Server"
  value       = aws_route53_zone.this.name_servers
}

output "certificate_arn" {
  description = "ACM 인증서 ARN (수동 ALB HTTPS Listener에 사용)"
  value       = aws_acm_certificate.this.arn
}

output "certificate_domain_validation_options" {
  description = "수동 등록할 ACM DNS 검증 레코드"
  value       = aws_acm_certificate.this.domain_validation_options
}
