# CT-37: Public and private route tables + subnet associations

# Public route table - routes internet traffic through the Internet Gateway
resource "aws_route_table" "public_rt_19thoct" {
  vpc_id = aws_vpc.vpc_19thoct.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_19thoct.id
  }

  tags = {
    Name    = "19thoct-public-rt"
    Project = "19thoct"
  }
}

# Private route table - routes internet traffic through the NAT Gateway
resource "aws_route_table" "private_rt_19thoct" {
  vpc_id = aws_vpc.vpc_19thoct.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_19thoct.id
  }

  tags = {
    Name    = "19thoct-private-rt"
    Project = "19thoct"
  }
}

# Public subnet associations
resource "aws_route_table_association" "public_rta_1_19thoct" {
  subnet_id      = aws_subnet.public_subnet_1_19thoct.id
  route_table_id = aws_route_table.public_rt_19thoct.id
}

resource "aws_route_table_association" "public_rta_2_19thoct" {
  subnet_id      = aws_subnet.public_subnet_2_19thoct.id
  route_table_id = aws_route_table.public_rt_19thoct.id
}

# Private subnet associations
resource "aws_route_table_association" "private_rta_1_19thoct" {
  subnet_id      = aws_subnet.private_subnet_1_19thoct.id
  route_table_id = aws_route_table.private_rt_19thoct.id
}

resource "aws_route_table_association" "private_rta_2_19thoct" {
  subnet_id      = aws_subnet.private_subnet_2_19thoct.id
  route_table_id = aws_route_table.private_rt_19thoct.id
}