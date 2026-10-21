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

resource "aws_internet_gateway" "igw_19thoct" {
  vpc_id = aws_vpc.vpc_19thoct.id

  tags = {
    Name    = "19thoct-igw"
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

#creating security group for jenkins
resource "aws_security_group" "jenkins_sg_19thoct" {
  name        = "19thoct-sg"
  description = "Security group for 19thoct jenkins project"
  vpc_id      = aws_vpc.vpc_19thoct.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

#creating security group for ansible
resource "aws_security_group" "ansible_sg_19thoct" {
  name        = "19thoct-ansible-sg"
  description = "Security group for 19thoct Ansible project"
  vpc_id      = aws_vpc.vpc_19thoct.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name    = "19thoct-ansible-sg"
    Project = "19thoct"
  }
}

#creating security group for ALB
resource "aws_security_group" "alb_19thoct" {
  name        = "19thoct-alb-sg"
  description = "Security group for 19thoct ALB project"
  vpc_id      = aws_vpc.vpc_19thoct.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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
    Name    = "19thoct-alb-sg"
    Project = "19thoct"
  }
}

#creating security group for sonarqube
resource "aws_security_group" "sonarqube_sg_19thoct" {
  name        = "19thoct-sonarqube-sg"
  description = "Security group for 19thoct SonarQube project"
  vpc_id      = aws_vpc.vpc_19thoct.id

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name    = "19thoct-sonarqube-sg"
    Project = "19thoct"
  }
}

#creating security group for nexus
resource "aws_security_group" "nexus_sg_19thoct" {
  name        = "19thoct-nexus-sg"
  description = "Security group for 19thoct Nexus project"
  vpc_id      = aws_vpc.vpc_19thoct.id

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 8085
    to_port     = 8085
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
    Name    = "19thoct-nexus-sg"
    Project = "19thoct"
  }
}

#creating security group for docker hosts
resource "aws_security_group" "docker_hosts_sg_19thoct" {
  name        = "19thoct-docker-hosts-sg"
  description = "Security group for 19thoct Docker Hosts project"
  vpc_id      = aws_vpc.vpc_19thoct.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name    = "19thoct-docker-hosts-sg"
    Project = "19thoct"
  }
}

#creating security group for bastion host
resource "aws_security_group" "bastion_sg_19thoct" {
  name        = "19thoct-bastion-sg"
  description = "Security group for 19thoct Bastion Host project"
  vpc_id      = aws_vpc.vpc_19thoct.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name    = "19thoct-bastion-sg"
    Project = "19thoct"
  }
}

#creating security group for RDS  
resource "aws_security_group" "rds_sg_19thoct" {
  name        = "19thoct-rds-sg"
  description = "Security group for 19thoct RDS project"
  vpc_id      = aws_vpc.vpc_19thoct.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.docker_hosts_sg_19thoct.id, aws_security_group.bastion_sg_19thoct.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "19thoct-rds-sg"
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


#creating elastic ip for nat gateway 
resource "aws_eip" "nat_eip_1_19thoct" {
  domain = "vpc"

  tags = {
    Name    = "19thoct-nat-eip-1"
    Project = "19thoct"
  }
}


#creating nat gateway 
resource "aws_nat_gateway" "nat_19thoct" {
  allocation_id = aws_eip.nat_eip_1_19thoct.id
  subnet_id     = aws_subnet.public_subnet_1_19thoct.id
  depends_on    = [aws_internet_gateway.igw_19thoct]
  tags = {
    Name    = "19thoct-nat-gateway-1"
    Project = "19thoct"
  }
}



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

