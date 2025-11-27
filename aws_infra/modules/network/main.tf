resource "aws_vpc" "main" {
cidr_block = var.vpc_cidr
enable_dns_support = true
enable_dns_hostnames = true
tags = { Name = "prod-vpc" }
}

# Private subnets for ECS tasks
resource "aws_subnet" "private" {
  count              = length(var.azs)
  vpc_id             = aws_vpc.main.id
  cidr_block         = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone  = var.azs[count.index]
  tags               = { Name = "private-subnet-${count.index}" }
}

# Internet Gateway for public subnets
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "prod-igw" }
}

# Public subnets for ALB
resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index + 100)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet-${count.index}" }
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "public-rt" }
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}