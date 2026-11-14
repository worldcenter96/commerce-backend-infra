output "artifact_bucket_name" {
  description = "배포 아티팩트 S3 Bucket 이름"
  value       = aws_s3_bucket.artifact.bucket
}

output "artifact_bucket_arn" {
  description = "배포 아티팩트 S3 Bucket ARN (수동 IAM 구성에 사용)"
  value       = aws_s3_bucket.artifact.arn
}

output "codedeploy_app_name" {
  description = "CodeDeploy Application 이름 (수동 Deployment Group 구성에 사용)"
  value       = aws_codedeploy_app.this.name
}
