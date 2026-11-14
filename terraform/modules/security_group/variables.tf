variable "name" {
  description = "Security Group 이름 (Name 태그 동일)"
  type        = string
}

variable "vpc_id" {
  description = "Security Group을 생성할 VPC ID"
  type        = string
}

variable "ingress_rules" {
  description = "Ingress 규칙. key는 규칙 식별자. ip_protocol이 -1이면 port를 생략한다"
  type = map(object({
    ip_protocol                  = string
    from_port                    = optional(number)
    to_port                      = optional(number)
    cidr_ipv4                    = optional(string)
    referenced_security_group_id = optional(string)
  }))
  default = {}
}

variable "egress_rules" {
  description = "Egress 규칙. 비어 있으면 egress 규칙을 생성하지 않는다"
  type = map(object({
    ip_protocol                  = string
    from_port                    = optional(number)
    to_port                      = optional(number)
    cidr_ipv4                    = optional(string)
    referenced_security_group_id = optional(string)
  }))
  default = {}
}
