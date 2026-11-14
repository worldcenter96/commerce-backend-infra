variable "name" {
  description = "EC2 Name 태그"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "subnet_id" {
  description = "배치할 Subnet ID"
  type        = string
}

variable "security_group_ids" {
  description = "연결할 Security Group ID 목록"
  type        = list(string)
}

variable "associate_public_ip_address" {
  description = "Public IP 할당 여부"
  type        = bool
}

variable "key_name" {
  description = "참조할 기존 Key Pair 이름"
  type        = string
}

variable "metadata_http_tokens" {
  description = "IMDS 토큰 설정 (required = IMDSv2 강제)"
  type        = string
}

variable "root_volume_size" {
  description = "Root volume 크기 (GiB)"
  type        = number
}

variable "root_volume_encrypted" {
  description = "Root volume 암호화 여부"
  type        = bool
}
