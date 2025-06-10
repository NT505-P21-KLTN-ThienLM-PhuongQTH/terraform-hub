# VPC Module
resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name = var.name
  }
}

# Local variables to filter out empty subnets
locals {
  filtered_public_subnets  = [for cidr in var.public_subnets : cidr if cidr != ""]
  filtered_private_subnets = [for cidr in var.private_subnets : cidr if cidr != ""]
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(local.filtered_public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(local.filtered_public_subnets, count.index)
  availability_zone       = element(var.azs, count.index % length(var.azs))
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "${var.name}-public-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(local.filtered_private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(local.filtered_private_subnets, count.index)
  availability_zone = element(var.azs, count.index % length(var.azs))

  tags = {
    Name = "${var.name}-private-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  count  = length(local.filtered_public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.name
  }
}

# Public Route Tables
resource "aws_route_table" "public" {
  count  = length(local.filtered_public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(local.filtered_public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# NAT Gateway
resource "aws_eip" "gateway" {
  count = var.enable_nat_gateway && length(local.filtered_public_subnets) > 0 ? length(local.filtered_public_subnets) : 0
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway && length(local.filtered_public_subnets) > 0 ? length(local.filtered_public_subnets) : 0
  allocation_id = aws_eip.gateway[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.name}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# Private Route Tables
resource "aws_route_table" "private" {
  count  = length(local.filtered_private_subnets)
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway && length(aws_nat_gateway.main) > 0 ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index % length(aws_nat_gateway.main)].id
    }
  }

  dynamic "route" {
    for_each = !var.enable_nat_gateway && var.gateway_instance != "" ? [1] : []
    content {
      cidr_block         = "0.0.0.0/0"
      network_interface_id = var.gateway_instance
    }
  }

  tags = {
    Name = "${var.name}-private-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(local.filtered_private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
