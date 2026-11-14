variable "name" {
  description = "ALB 이름"
  type        = string
}

variable "internal" {
  description = "internal 여부"
  type        = bool
}

variable "subnet_ids" {
  description = "ALB를 배치할 Subnet ID 목록 (2개 이상 AZ)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "ALB에 연결할 Security Group ID 목록"
  type        = list(string)
}
