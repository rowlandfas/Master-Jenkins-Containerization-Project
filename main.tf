terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_vpc" "vpc_19thoct" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "19thoct-vpc"
    Project = "19thoct"
  }
}

# ---------- Subnets (Kenneth) ----------

# Public subnets: bastion host, NAT gateways, load balancer
resource "aws_subnet" "public_subnet_1_19thoct" {
  vpc_id                  = aws_vpc.vpc_19thoct.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "19thoct-public-subnet-1"
    Project = "19thoct"
  }
}

resource "aws_subnet" "public_subnet_2_19thoct" {
  vpc_id                  = aws_vpc.vpc_19thoct.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "19thoct-public-subnet-2"
    Project = "19thoct"
  }
}

# Private subnets: Docker hosts and CI/CD servers
resource "aws_subnet" "private_subnet_1_19thoct" {
  vpc_id            = aws_vpc.vpc_19thoct.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-3a"

  tags = {
    Name    = "19thoct-private-subnet-1"
    Project = "19thoct"
  }
}

resource "aws_subnet" "private_subnet_2_19thoct" {
  vpc_id            = aws_vpc.vpc_19thoct.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-3b"

  tags = {
    Name    = "19thoct-private-subnet-2"
    Project = "19thoct"
  }
}
