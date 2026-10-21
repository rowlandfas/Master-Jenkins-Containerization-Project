# ---------- Subnets (Kenneth) ----------

# Public subnets: bastion host, NAT gateways, load balancer
resource "aws_subnet" "oct2026_public_subnet_1" {
  vpc_id                  = aws_vpc.oct2026_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}_public_subnet_1"
  }
}

resource "aws_subnet" "oct2026_public_subnet_2" {
  vpc_id                  = aws_vpc.oct2026_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}_public_subnet_2"
  }
}

# Private subnets: Docker hosts and CI/CD servers
resource "aws_subnet" "oct2026_private_subnet_1" {
  vpc_id            = aws_vpc.oct2026_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "${local.name}_private_subnet_1"
  }
}

resource "aws_subnet" "oct2026_private_subnet_2" {
  vpc_id            = aws_vpc.oct2026_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-3b"

  tags = {
    Name = "${local.name}_private_subnet_2"
  }
}
