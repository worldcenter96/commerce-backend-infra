# 수동 작업(infrastructure-spec.md §5.2)에 필요한 값 조회용 출력

output "route53_name_servers" {
  description = "registrar NS 위임에 사용할 Name Server"
  value       = module.dns_certificate.name_servers
}

output "acm_certificate_arn" {
  description = "수동 ALB HTTPS Listener에 사용할 ACM 인증서 ARN"
  value       = module.dns_certificate.certificate_arn
}

output "acm_domain_validation_options" {
  description = "수동 등록할 ACM DNS 검증 CNAME"
  value       = module.dns_certificate.certificate_domain_validation_options
}

output "nlb_dns_name" {
  description = "Route 53 Alias 레코드 대상 NLB DNS 이름"
  value       = module.nlb.dns_name
}

output "nlb_zone_id" {
  description = "Route 53 Alias 레코드 대상 NLB Hosted Zone ID"
  value       = module.nlb.zone_id
}

output "nlb_eip" {
  description = "NLB 고정 Public IP"
  value       = module.nlb.eip_public_ip
}

output "nlb_target_group_arn" {
  description = "ALB를 수동 등록할 NLB Target Group ARN"
  value       = module.nlb.target_group_arn
}

output "alb_arn" {
  description = "수동 Listener 생성 및 NLB Target Group 등록 대상 ALB ARN"
  value       = module.alb.arn
}

output "ec2_private_ips" {
  description = "EC2 Private IP"
  value       = { for k, m in module.ec2 : k => m.private_ip }
}

output "bastion_public_ip" {
  description = "Bastion Public IP"
  value       = module.ec2["bastion"].public_ip
}

output "rds_address" {
  description = "RDS endpoint 주소"
  value       = module.rds.address
}

output "rds_master_user_secret_arn" {
  description = "RDS master password가 저장된 Secrets Manager secret ARN"
  value       = module.rds.master_user_secret_arn
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint"
  value       = module.elasticache.primary_endpoint_address
}

output "artifact_bucket_name" {
  description = "배포 아티팩트 S3 Bucket 이름"
  value       = module.cicd.artifact_bucket_name
}

output "codedeploy_app_name" {
  description = "CodeDeploy Application 이름"
  value       = module.cicd.codedeploy_app_name
}
