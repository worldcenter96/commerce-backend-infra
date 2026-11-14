# infrastructure-spec.md §2 Common
# terraform_state: local -> backend 블록을 두지 않는다 (기본 local backend).
terraform {
  required_version = "1.17.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.71.0"
    }
  }
}
