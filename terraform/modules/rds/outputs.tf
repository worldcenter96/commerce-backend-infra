output "address" {
  description = "RDS endpoint 주소"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS 포트"
  value       = aws_db_instance.this.port
}

output "master_user_secret_arn" {
  description = "master password가 저장된 Secrets Manager secret ARN"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
