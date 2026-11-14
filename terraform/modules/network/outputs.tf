output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

# internet-facing NLB 등 Public Subnet 사용 리소스는 Internet Gateway 연결 이후 생성되어야 하므로
# Subnet ID 출력이 Internet Gateway에 의존하도록 한다.
output "subnet_ids" {
  description = "Subnet 논리 이름별 Subnet ID"
  value       = { for k, s in aws_subnet.this : k => s.id }
  depends_on  = [aws_internet_gateway.this]
}
