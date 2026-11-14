output "id" {
  description = "EC2 Instance ID"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP (할당된 경우)"
  value       = aws_instance.this.public_ip
}
