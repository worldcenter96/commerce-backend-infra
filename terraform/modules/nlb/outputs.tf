output "dns_name" {
  description = "NLB DNS 이름 (Route 53 Alias 대상)"
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "NLB Hosted Zone ID (Route 53 Alias 대상)"
  value       = aws_lb.this.zone_id
}

output "eip_public_ip" {
  description = "NLB 고정 Public IP"
  value       = aws_eip.this.public_ip
}

output "target_group_arn" {
  description = "NLB Target Group ARN"
  value       = aws_lb_target_group.this.arn
}
