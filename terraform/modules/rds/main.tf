terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_db_subnet_group" "this" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.subnet_group_name
  }
}

resource "aws_db_parameter_group" "this" {
  name   = var.parameter_group.name
  family = var.parameter_group.family

  dynamic "parameter" {
    for_each = var.parameter_group.parameters

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = {
    Name = var.parameter_group.name
  }
}

# master password는 manage_master_user_password로 Secrets Manager가 관리한다.
# kms_key_id, master_user_secret_kms_key_id는 생략하여 AWS 관리형 키를 사용한다.
resource "aws_db_instance" "this" {
  identifier     = var.identifier
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted

  multi_az          = var.multi_az
  availability_zone = var.availability_zone

  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name
  vpc_security_group_ids = var.security_group_ids
  port                   = var.port
  publicly_accessible    = var.publicly_accessible

  db_name                     = var.db_name
  username                    = var.username
  manage_master_user_password = var.manage_master_user_password

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
}
