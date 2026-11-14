terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Key Pair는 기존 리소스를 이름으로만 참조한다. IAM Instance Profile과 user_data는 사용하지 않는다.
resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.key_name

  metadata_options {
    http_tokens = var.metadata_http_tokens
  }

  root_block_device {
    volume_size = var.root_volume_size
    encrypted   = var.root_volume_encrypted
  }

  tags = {
    Name = var.name
  }
}
