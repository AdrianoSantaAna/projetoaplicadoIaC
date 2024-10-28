resource "aws_vpc" "anaexames" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.anaexames.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "sa-east-1a"
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.anaexames.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "sa-east-1a"
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.anaexames.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "sa-east-1b"  
}

resource "aws_internet_gateway" "internal_gw" {
  vpc_id = aws_vpc.anaexames.id
}

resource "aws_eip" "anaexames_eip" {
}

resource "aws_nat_gateway" "anaexames_ntgw" {
  allocation_id = aws_eip.anaexames_eip.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.anaexames.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internal_gw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.anaexames.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.anaexames_ntgw.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "private_association_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "private_association_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.rt_private.id
}
