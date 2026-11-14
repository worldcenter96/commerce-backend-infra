variable "subnet_group_name" {
  description = "ElastiCache Subnet Group 이름"
  type        = string
}

variable "subnet_ids" {
  description = "ElastiCache Subnet Group Subnet ID 목록"
  type        = list(string)
}

variable "replication_group_id" {
  description = "Replication Group ID"
  type        = string
}

variable "description" {
  description = "Replication Group 설명 (Provider 필수 인자)"
  type        = string
}

variable "engine" {
  description = "Cache engine"
  type        = string
}

variable "engine_version" {
  description = "Cache engine version"
  type        = string
}

variable "node_type" {
  description = "Node type"
  type        = string
}

variable "num_cache_clusters" {
  description = "노드 수 (primary + replica)"
  type        = number
}

variable "port" {
  description = "Redis 포트"
  type        = number
}

variable "security_group_ids" {
  description = "Security Group ID 목록"
  type        = list(string)
}

variable "transit_encryption_enabled" {
  description = "전송 구간 암호화(TLS) 여부"
  type        = bool
}

variable "transit_encryption_mode" {
  description = "전송 구간 암호화 모드"
  type        = string
}

variable "at_rest_encryption_enabled" {
  description = "저장 암호화 여부"
  type        = bool
}
