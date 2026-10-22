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
# Ticket: Create Docker Host - ports open only to approved sources
resource "aws_security_group" "docker_hosts_sg_19thoct" {
  name        = "19thoct-docker-hosts-sg"
  description = "Security group for 19thoct Docker Hosts project"
  vpc_id      = aws_vpc.vpc_19thoct.id

  ingress {
    description     = "BankApp traffic from the load balancer only"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_19thoct.id]
  }

  ingress {
    description     = "SSH from bastion and Ansible only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg_19thoct.id, aws_security_group.ansible_sg_19thoct.id]
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
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
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

# ---------- Docker hosts (Kenneth) ----------

# Latest Ubuntu 22.04 LTS image from Canonical
data "aws_ami" "ubuntu_19thoct" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM role so the Docker hosts can be managed through SSM Session Manager
resource "aws_iam_role" "docker_hosts_role_19thoct" {
  name = "19thoct-docker-hosts-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name    = "19thoct-docker-hosts-role"
    Project = "19thoct"
  }
}

resource "aws_iam_role_policy_attachment" "docker_hosts_ssm_19thoct" {
  role       = aws_iam_role.docker_hosts_role_19thoct.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "docker_hosts_profile_19thoct" {
  name = "19thoct-docker-hosts-profile"
  role = aws_iam_role.docker_hosts_role_19thoct.name
}

# Launch template: how every Docker host is built
resource "aws_launch_template" "docker_hosts_lt_19thoct" {
  name_prefix   = "19thoct-docker-hosts-"
  image_id      = data.aws_ami.ubuntu_19thoct.id
  instance_type = var.docker_instance_type
  key_name      = aws_key_pair.key_pair_19thoct.key_name

  vpc_security_group_ids = [aws_security_group.docker_hosts_sg_19thoct.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.docker_hosts_profile_19thoct.name
  }

  # Require IMDSv2 so instance credentials can't be stolen through the old metadata endpoint
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  # Encrypted disk for images, containers and logs
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euo pipefail

    # Save all output to a log file so failed boots can be investigated
    exec > >(tee -a /var/log/docker-host-setup.log) 2>&1

    # Retry a command up to 5 times, 15 seconds apart,
    # so a short network blip doesn't leave a host without Docker
    retry() {
      local attempt=1
      until "$@"; do
        if [ "$attempt" -ge 5 ]; then
          echo "FAILED after $attempt attempts: $*"
          return 1
        fi
        echo "Attempt $attempt failed: $*. Retrying in 15 seconds..."
        attempt=$((attempt + 1))
        sleep 15
      done
    }

    # Wait up to 5 minutes if Ubuntu's automatic updates are holding the apt lock
    APT="apt-get -o DPkg::Lock::Timeout=300"

    # Install Docker Engine from Docker's official repository
    retry $APT update -y
    retry $APT install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    retry curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /tmp/docker.gpg
    gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg /tmp/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
    retry $APT update -y
    retry $APT install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Docker daemon settings:
    # - rotate container logs so the disk never fills up
    # - keep containers running if the Docker daemon restarts
    # The daemon only listens on the local socket, never on a network port
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json <<'JSON'
    {
      "log-driver": "json-file",
      "log-opts": { "max-size": "10m", "max-file": "3" },
      "live-restore": true
    }
    JSON

    # Folder for any persistent application data
    mkdir -p /opt/bankapp/data
    chown ubuntu:ubuntu /opt/bankapp/data

    # Only root and the ubuntu user (used by Ansible) can control Docker
    usermod -aG docker ubuntu

    # Start Docker now and on every boot
    systemctl enable docker
    systemctl restart docker

    # Confirm Docker is actually running before marking setup complete
    systemctl is-active --quiet docker
    echo "Docker host setup completed successfully"
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "19thoct-docker-host"
      Project = "19thoct"
      Role    = "docker-host"
    }
  }

  tags = {
    Name    = "19thoct-docker-hosts-lt"
    Project = "19thoct"
  }
}

# Auto scaling group: keeps Docker hosts running across both private subnets
resource "aws_autoscaling_group" "docker_hosts_asg_19thoct" {
  name                = "19thoct-docker-hosts-asg"
  min_size            = var.docker_min_size
  desired_capacity    = var.docker_desired_capacity
  max_size            = var.docker_max_size
  vpc_zone_identifier = [aws_subnet.private_subnet_1_19thoct.id, aws_subnet.private_subnet_2_19thoct.id]

  # EC2 health checks for now. Switch to "ELB" once the load balancer target group exists.
  # 300 seconds gives each host time to finish installing Docker before it is checked.
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.docker_hosts_lt_19thoct.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "19thoct-docker-host"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "19thoct"
    propagate_at_launch = true
  }
}

# Add hosts when average CPU goes above 70 percent, remove them when it drops
resource "aws_autoscaling_policy" "docker_hosts_cpu_19thoct" {
  name                   = "19thoct-docker-hosts-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.docker_hosts_asg_19thoct.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70
  }
}
