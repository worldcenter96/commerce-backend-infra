output "arn" {
  description = "ALB ARN (수동 Listener 생성 및 NLB Target Group 등록 대상)"
  value       = aws_lb.this.arn
}

output "dns_name" {
  description = "ALB DNS 이름"
  value       = aws_lb.this.dns_name
}
