variable "name" {
  description = "NLB 이름"
  type        = string
}

variable "eip_name" {
  description = "NLB에 연결할 Elastic IP Name 태그"
  type        = string
}

variable "internal" {
  description = "internal 여부 (false = internet-facing)"
  type        = bool
}

variable "subnet_id" {
  description = "NLB를 배치할 Subnet ID (subnet_mapping)"
  type        = string
}

variable "security_group_ids" {
  description = "NLB에 연결할 Security Group ID 목록 (생성 시에만 연결 가능)"
  type        = list(string)
}

variable "enable_cross_zone_load_balancing" {
  description = "Cross-Zone Load Balancing 사용 여부"
  type        = bool
}

variable "vpc_id" {
  description = "Target Group VPC ID"
  type        = string
}

variable "target_group" {
  description = "Listener default action 대상 Target Group"
  type = object({
    name        = string
    target_type = string
    protocol    = string
    port        = number
    health_check = object({
      protocol = string
      path     = string
      matcher  = string
    })
  })
}

variable "listener" {
  description = "NLB Listener"
  type = object({
    name     = string
    port     = number
    protocol = string
  })
}
