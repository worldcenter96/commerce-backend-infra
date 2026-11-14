# infrastructure-spec.md §2 Common (region, default_tags)
# default_tags는 Child Module의 모든 리소스에 적용된다.
provider "aws" {
  region = local.region

  default_tags {
    tags = local.default_tags
  }
}
