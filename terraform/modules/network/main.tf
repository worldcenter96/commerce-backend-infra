terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name = each.value.name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.internet_gateway_name
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = var.nat_gateway.eip_name
  }
}

# Public NAT Gateway는 VPC에 Internet Gateway가 연결된 후 생성되어야 한다 (AWS Provider 문서 권장).
resource "aws_nat_gateway" "this" {
  connectivity_type = "public"
  subnet_id         = aws_subnet.this[var.nat_gateway.subnet_key].id
  allocation_id     = aws_eip.nat.id

  tags = {
    Name = var.nat_gateway.name
  }

  depends_on = [aws_internet_gateway.this]
}

# Public Route Table: 0.0.0.0/0 -> Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = var.public_route_table.name
  }
}

resource "aws_route_table_association" "public" {
  for_each = toset(var.public_route_table.subnet_keys)

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}

# NAT Route Table: 0.0.0.0/0 -> NAT Gateway
resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = var.nat_route_table.name
  }
}

resource "aws_route_table_association" "nat" {
  for_each = toset(var.nat_route_table.subnet_keys)

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.nat.id
}

# Local Route Table: VPC local 경로만 사용
resource "aws_route_table" "local" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.local_route_table.name
  }
}

resource "aws_route_table_association" "local" {
  for_each = toset(var.local_route_table.subnet_keys)

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.local.id
}
