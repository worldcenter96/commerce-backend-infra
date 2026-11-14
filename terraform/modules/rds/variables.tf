variable "subnet_group_name" {
  description = "DB Subnet Group 이름"
  type        = string
}

variable "subnet_ids" {
  description = "DB Subnet Group Subnet ID 목록 (2개 이상 AZ)"
  type        = list(string)
}

variable "parameter_group" {
  description = "DB Parameter Group"
  type = object({
    name   = string
    family = string
    parameters = list(object({
      name  = string
      value = string
    }))
  })
}

variable "identifier" {
  description = "DB Instance identifier"
  type        = string
}

variable "engine" {
  description = "DB engine"
  type        = string
}

variable "engine_version" {
  description = "DB engine version"
  type        = string
}

variable "instance_class" {
  description = "DB instance class"
  type        = string
}

variable "allocated_storage" {
  description = "저장 용량 (GiB)"
  type        = number
}

variable "storage_type" {
  description = "스토리지 유형"
  type        = string
}

variable "storage_encrypted" {
  description = "저장 암호화 여부"
  type        = bool
}

variable "multi_az" {
  description = "Multi-AZ 여부"
  type        = bool
}

variable "availability_zone" {
  description = "DB Instance AZ"
  type        = string
}

variable "security_group_ids" {
  description = "DB Instance Security Group ID 목록"
  type        = list(string)
}

variable "port" {
  description = "DB 포트"
  type        = number
}

variable "publicly_accessible" {
  description = "Public 접근 허용 여부"
  type        = bool
}

variable "db_name" {
  description = "초기 DB 이름"
  type        = string
}

variable "username" {
  description = "master username"
  type        = string
}

variable "manage_master_user_password" {
  description = "Secrets Manager로 master password 관리 여부"
  type        = bool
}

variable "backup_retention_period" {
  description = "자동 백업 보존 기간 (일)"
  type        = number
}

variable "skip_final_snapshot" {
  description = "삭제 시 최종 스냅샷 생략 여부"
  type        = bool
}

variable "deletion_protection" {
  description = "삭제 보호 여부"
  type        = bool
}
