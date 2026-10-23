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
    description = "Jenkins access from load balancer and bastion"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"

    security_groups = [
      aws_security_group.jenkins_alb_19thoct.id,
      aws_security_group.bastion_sg_19thoct.id
    ]
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


#Bastion Server
resource "aws_instance" "bastion_19thoct" {
  ami                    = data.aws_ami.redhat_19thoct.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet_1_19thoct.id
  vpc_security_group_ids = [aws_security_group.bastion_sg_19thoct.id]
  key_name               = aws_key_pair.key_pair_19thoct.key_name

  associate_public_ip_address = true

  tags = {
    Name    = "19thoct-bastion"
    Project = "19thoct"
  }
}
# ==========================================================
# CT-12: Nexus Server
# Nexus stores our build artifacts (Maven) and Docker images.
# It lives in a PRIVATE subnet, so we reach it through the bastion host.
# ==========================================================

# Find the latest Red Hat Enterprise Linux 9 image (AMI) in our region.
data "aws_ami" "redhat_19thoct" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat's official AWS account

  filter {
    name   = "name"
    values = ["RHEL-9.*_HVM-*-x86_64-*-Hourly2-GP3"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "nexus_19thoct" {
  ami                         = data.aws_ami.redhat_19thoct.id
  instance_type               = "t3.medium"                              # Nexus needs at least 4GB RAM, t3.medium has 4GB
  subnet_id                   = aws_subnet.private_subnet_1_19thoct.id   # private subnet (can't be accessed from the internet)
  vpc_security_group_ids      = [aws_security_group.nexus_sg_19thoct.id] # Use the Nexus security group (ports 22, 8081, 8085)
  associate_public_ip_address = false
  key_name                    = aws_key_pair.key_pair_19thoct.key_name # Use the team key pair so we can SSH in through the bastion

  # Disk size - Nexus stores artifacts and Docker images so it needs space
  root_block_device {
    volume_size = 30
    volume_type = "gp3"

    # This tag tells the backup policy (below) to snapshot this disk
    tags = {
      Name    = "19thoct-nexus-disk"
      Project = "19thoct"
      Backup  = "nexus-daily"
    }
  }

  # Install script - runs ONE TIME when the server first starts
  user_data = file("${path.module}/nexus_userdata.sh")

  tags = {
    Name    = "19thoct-nexus"
    Project = "19thoct"
  }
}

# ---------- Nexus backups (CT-12) ----------

# A role that lets the AWS backup service (DLM) take snapshots for us
resource "aws_iam_role" "dlm_role_19thoct" {
  name = "19thoct-dlm-role"

  # Allow the DLM service to use this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "dlm.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name    = "19thoct-dlm-role"
    Project = "19thoct"
  }
}

# Give the role AWS's ready-made permissions for creating and deleting snapshots
resource "aws_iam_role_policy_attachment" "dlm_policy_19thoct" {
  role       = aws_iam_role.dlm_role_19thoct.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
}

# The backup schedule: snapshot the Nexus disk every day, keep the last 7
resource "aws_dlm_lifecycle_policy" "nexus_backup_19thoct" {
  description        = "Daily snapshot of the Nexus disk keep 7 days"
  execution_role_arn = aws_iam_role.dlm_role_19thoct.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    # Only back up disks with this tag (our Nexus disk)
    target_tags = {
      Backup = "nexus-daily"
    }

    schedule {
      name = "Daily Nexus snapshot"

      # Take a snapshot every 24 hours at 02:00 (UTC)
      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["02:00"]
      }

      # Keep the 7 newest snapshots, delete anything older
      retain_rule {
        count = 7
      }

      # Copy the disk's tags onto each snapshot so we can find them easily
      copy_tags = true
    }
  }

  tags = {
    Name    = "19thoct-nexus-backup"
    Project = "19thoct"
  }
}

# ---------- Docker hosts (Kenneth) ----------

# The Docker hosts use the same Red Hat Enterprise Linux 9 image as Nexus
# (data "aws_ami" "redhat_19thoct" above)

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
  image_id      = data.aws_ami.redhat_19thoct.id
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
    device_name = data.aws_ami.redhat_19thoct.root_device_name

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  # Install script lives in its own file so main.tf stays readable
  user_data = base64encode(file("${path.module}/docker-host-userdata.sh"))

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

# Latest Ubuntu 22.04 LTS image from Canonical, used by the Jenkins server
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

# ==================================================
# JENKINS SERVER
# Private server for the BankApp CI/CD pipeline.
# ==================================================

resource "aws_instance" "jenkins_19thoct" {
  ami           = data.aws_ami.redhat_19thoct.id
  instance_type = "t3.medium"

  subnet_id = aws_subnet.private_subnet_1_19thoct.id

  vpc_security_group_ids = [
    aws_security_group.jenkins_sg_19thoct.id
  ]

  key_name                    = aws_key_pair.key_pair_19thoct.key_name
  associate_public_ip_address = false

  # Require the more secure instance metadata service.
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Encrypted storage for Jenkins configuration,
  # plugins, workspaces and build files.
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name    = "19thoct-jenkins-disk"
      Project = "19thoct"
    }
  }

  # Recreate the instance when its installation script changes.
  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail

    # Record installation output for troubleshooting.
    exec > >(tee -a /var/log/jenkins-setup.log) 2>&1

    # Retry commands if the network is temporarily unavailable.
    retry() {
      local attempt=1

      until "$@"; do
        if [ "$attempt" -ge 5 ]; then
          echo "Command failed after $attempt attempts: $*"
          return 1
        fi

        echo "Retrying in 15 seconds..."
        attempt=$((attempt + 1))
        sleep 15
      done
    }

    # Set the server hostname.
    hostnamectl set-hostname jenkins-19thoct
    echo "preserve_hostname: true" \
      > /etc/cloud/cloud.cfg.d/99_hostname.cfg

    # Refresh Red Hat package information.
    retry dnf -y makecache

    # Install Java before Jenkins, plus the build tools.
    retry dnf -y install \
      ca-certificates \
      wget \
      fontconfig \
      java-21-openjdk-devel \
      git \
      maven \
      unzip

    # Add the official Jenkins LTS RPM repository.
    retry wget -O /etc/yum.repos.d/jenkins.repo \
      https://pkg.jenkins.io/rpm-stable/jenkins.repo

    # Download and import the Jenkins repository signing key.
    retry wget -O /tmp/jenkins-signing-key.asc \
      https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key

    rpm --import /tmp/jenkins-signing-key.asc
    rm -f /tmp/jenkins-signing-key.asc

    # Install Jenkins.
    retry dnf -y install jenkins

    # Reload service definitions and start Jenkins.
    systemctl daemon-reload
    systemctl enable --now jenkins

    # Check the service and installed tools.
    systemctl is-active --quiet jenkins
    java -version
    git --version
    mvn -version

    echo "Jenkins server setup completed successfully."
  EOF

  # Wait until the outbound network path is configured
  # before starting the installation script.
  depends_on = [
    aws_route_table_association.public_rta_1_19thoct,
    aws_route_table_association.private_rta_1_19thoct
  ]

  tags = {
    Name    = "19thoct-jenkins"
    Project = "19thoct"
    Role    = "jenkins"
  }
}



#creating sonarqube server
# SonarQube server
resource "aws_instance" "sonarqube_19thoct" {
  ami                         = data.aws_ami.redhat_19thoct.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.private_subnet_2_19thoct.id
  vpc_security_group_ids      = [aws_security_group.sonarqube_sg_19thoct.id]
  associate_public_ip_address = false
  key_name                    = aws_key_pair.key_pair_19thoct.key_name

  user_data = file("${path.module}/userdata-sonarqube.sh")

  depends_on = [
    aws_nat_gateway.nat_19thoct,
    aws_route_table_association.public_rta_1_19thoct,
    aws_route_table_association.private_rta_2_19thoct
  ]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true

    tags = {
      Name    = "19thoct-sonarqube-disk"
      Project = "19thoct"
      Backup  = "sonarqube-daily"
    }
  }

  tags = {
    Name    = "19thoct-sonarqube"
    Project = "19thoct"
  }
}

# SonarQube disk snapshots
resource "aws_dlm_lifecycle_policy" "sonarqube_backup_19thoct" {
  description        = "Daily SonarQube disk snapshots retain seven snapshots"
  execution_role_arn = aws_iam_role.dlm_role_19thoct.arn
  state              = "ENABLED"

  depends_on = [
    aws_iam_role_policy_attachment.dlm_policy_19thoct
  ]

  policy_details {
    resource_types = ["VOLUME"]

    target_tags = {
      Backup = "sonarqube-daily"
    }

    schedule {
      name = "Daily SonarQube snapshot"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["03:00"]
      }

      retain_rule {
        count = 7
      }

      copy_tags = true
    }
  }

  tags = {
    Name    = "19thoct-sonarqube-backup"
    Project = "19thoct"
  }
}

#SSL CERTIFICATE
# One shared certificate for the whole project.
# Covers everythingops.io and every subdomain (*.everythingops.io), so the
# BankApp, Jenkins and SonarQube load balancers can all use it.
resource "aws_acm_certificate" "bankapp_ssl" {
  domain_name               = "everythingops.io"
  subject_alternative_names = ["*.everythingops.io"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name    = "19thoct-shared-certificate"
    Project = "19thoct"
  }
}

data "aws_route53_zone" "bankapp_zone" {
  name         = "everythingops.io."
  private_zone = false
}

# everythingops.io and *.everythingops.io share the same validation record,
# so records are keyed by record name to avoid creating the same one twice
resource "aws_route53_record" "bankapp_validation" {
  for_each = {
    for form in aws_acm_certificate.bankapp_ssl.domain_validation_options :
    form.resource_record_name => {
      name   = form.resource_record_name
      record = form.resource_record_value
      type   = form.resource_record_type
    }...
  }

  zone_id         = data.aws_route53_zone.bankapp_zone.zone_id
  name            = each.value[0].name
  type            = each.value[0].type
  records         = [each.value[0].record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "bankapp_ssl_validation" {
  certificate_arn         = aws_acm_certificate.bankapp_ssl.arn
  validation_record_fqdns = [for record in aws_route53_record.bankapp_validation : record.fqdn]
}