output "primary_endpoint_address" {
  description = "Redis primary endpoint"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}
