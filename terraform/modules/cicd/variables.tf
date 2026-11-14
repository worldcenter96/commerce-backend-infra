variable "artifact_bucket" {
  description = "배포 아티팩트 S3 Bucket"
  type = object({
    name              = string
    force_destroy     = bool
    versioning_status = string
    sse_algorithm     = string
    public_access_block = object({
      block_public_acls       = bool
      ignore_public_acls      = bool
      block_public_policy     = bool
      restrict_public_buckets = bool
    })
  })
}

variable "codedeploy_app" {
  description = "CodeDeploy Application"
  type = object({
    name             = string
    compute_platform = string
  })
}
