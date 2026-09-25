resource "aws_vpc" "main" {

  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name}-vpc"
  }
}


resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name}-igw"
  }
}


resource "aws_subnet" "public" {

  count = 2

  vpc_id = aws_vpc.main.id

  cidr_block = local.public_subnets[count.index]

  availability_zone = local.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}-public-${count.index + 1}"
  }
}


resource "aws_subnet" "private" {

  count = 2

  vpc_id = aws_vpc.main.id

  cidr_block = local.private_subnets[count.index]

  availability_zone = local.availability_zones[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name}-private-${count.index + 1}"
  }
}


resource "aws_route_table" "public" {

  count = 2

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.name}-public-rt-${count.index + 1}"
  }
}


resource "aws_route_table_association" "public" {

  count = 2

  subnet_id = aws_subnet.public[count.index].id

  route_table_id = aws_route_table.public[count.index].id
}
resource "aws_eip" "nat" {

  count = 2

  domain = "vpc"

  tags = {
    Name = "${local.name}-nat-eip-${count.index + 1}"
  }
}


resource "aws_nat_gateway" "main" {

  count = 2

  allocation_id = aws_eip.nat[count.index].id

  subnet_id = aws_subnet.public[count.index].id

  depends_on = [
    aws_internet_gateway.main
  ]

  tags = {
    Name = "${local.name}-nat-${count.index + 1}"
  }
}
resource "aws_route_table" "private" {

  count = 2

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${local.name}-private-rt-${count.index + 1}"
  }
}


resource "aws_route_table_association" "private" {

  count = 2

  subnet_id = aws_subnet.private[count.index].id

  route_table_id = aws_route_table.private[count.index].id
}

