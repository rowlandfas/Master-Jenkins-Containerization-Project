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

resource "aws_security_group" "sg_19thoct" {
  name        = "19thoct-sg"
  description = "Security group for 19thoct project"
  vpc_id      = aws_vpc.vpc_19thoct.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "19thoct-sg"
    Project = "19thoct"
  }
}

resource "tls_private_key" "key_19thoct" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_19thoct" {
  content         = tls_private_key.key_19thoct.private_key_pem
  filename        = "./19thoct_private_key.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "key_pair_19thoct" {
  key_name   = "19thoct-key"
  public_key = tls_private_key.key_19thoct.public_key_openssh
}


#creating elastic ip for nat gateway 1
resource "aws_eip" "nat_eip_1_19thoct" {
  domain = "vpc"

  tags = {
    Name    = "19thoct-nat-eip-1"
    Project = "19thoct"
  }
}

#creating elastic ip for nat gateway 2
resource "aws_eip" "nat_eip_2_19thoct" {
  domain = "vpc"

  tags = {
    Name    = "19thoct-nat-eip-2"
    Project = "19thoct"
  }
}

#creating nat gateway 1
resource "aws_nat_gateway" "nat_19thoct" {
  allocation_id = aws_eip.nat_eip_1_19thoct.id
  subnet_id     = aws_subnet.public_subnet_1_19thoct.id

  tags = {
    Name    = "19thoct-nat-gateway-1"
    Project = "19thoct"
  }
}

#creating nat gateway 2
resource "aws_nat_gateway" "nat_2_19thoct" {
  allocation_id = aws_eip.nat_eip_2_19thoct.id
  subnet_id     = aws_subnet.public_subnet_2_19thoct.id

  tags = {
    Name    = "19thoct-nat-gateway-2"
    Project = "19thoct"
  }
}





