variable "vpc_name" {
  description = "VPC Name 태그"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR"
  type        = string
}

variable "subnets" {
  description = "Subnet 정의. key는 Subnet 논리 이름"
  type = map(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = optional(bool)
  }))
}

variable "internet_gateway_name" {
  description = "Internet Gateway Name 태그"
  type        = string
}

variable "nat_gateway" {
  description = "NAT Gateway 정의"
  type = object({
    name       = string
    eip_name   = string
    subnet_key = string
  })
}

variable "public_route_table" {
  description = "Internet Gateway 경로를 가지는 Route Table"
  type = object({
    name        = string
    subnet_keys = list(string)
  })
}

variable "nat_route_table" {
  description = "NAT Gateway 경로를 가지는 Route Table"
  type = object({
    name        = string
    subnet_keys = list(string)
  })
}

variable "local_route_table" {
  description = "VPC local 경로만 가지는 Route Table"
  type = object({
    name        = string
    subnet_keys = list(string)
  })
}
