resource "aws_vpc" "opt_vpc" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "network-optimized-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.opt_vpc.id
}

resource "aws_subnet" "pub_1" {
  vpc_id                  = aws_vpc.opt_vpc.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pub_2" {
  vpc_id                  = aws_vpc.opt_vpc.id
  cidr_block              = "10.2.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.opt_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub_1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pub_2.id
  route_table_id = aws_route_table.rt.id
}