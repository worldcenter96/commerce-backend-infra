terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# 배포 아티팩트 S3 Bucket
resource "aws_s3_bucket" "artifact" {
  bucket        = var.artifact_bucket.name
  force_destroy = var.artifact_bucket.force_destroy
}

resource "aws_s3_bucket_versioning" "artifact" {
  bucket = aws_s3_bucket.artifact.id

  versioning_configuration {
    status = var.artifact_bucket.versioning_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifact" {
  bucket = aws_s3_bucket.artifact.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.artifact_bucket.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifact" {
  bucket = aws_s3_bucket.artifact.id

  block_public_acls       = var.artifact_bucket.public_access_block.block_public_acls
  ignore_public_acls      = var.artifact_bucket.public_access_block.ignore_public_acls
  block_public_policy     = var.artifact_bucket.public_access_block.block_public_policy
  restrict_public_buckets = var.artifact_bucket.public_access_block.restrict_public_buckets
}

# CodeDeploy Deployment Group은 Terraform으로 관리하지 않는다.
resource "aws_codedeploy_app" "this" {
  name             = var.codedeploy_app.name
  compute_platform = var.codedeploy_app.compute_platform
}
