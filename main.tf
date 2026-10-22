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


#Bastion Server
resource "aws_instance" "bastion_19thoct" {
  ami                    = "ami-0884bba1ac5619645"
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

  # This script runs ONE TIME when the server first starts.
  # It installs Nexus and sets it up to start automatically.
  user_data = <<-EOF
    #!/bin/bash

    # Update the server and install wget and tar
    yum update -y
    yum install -y wget tar

    # Change the server's hostname so we know which server we're on
    hostnamectl set-hostname nexus-19thoct

    # Stop AWS's startup tool (cloud-init) changing the hostname back on reboot
    echo "preserve_hostname: true" > /etc/cloud/cloud.cfg.d/99_hostname.cfg

    # Create a user called nexus - Nexus should not run as root
    useradd --system --create-home --shell /bin/bash nexus

    # Download Nexus into /opt and unzip it
    # (Nexus now comes with its own Java, so we don't install Java separately)
    cd /opt
    wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/nexus-3.87.1-01-linux-x86_64.tar.gz
    tar -xzf nexus.tar.gz
    rm nexus.tar.gz

    # Rename the folder to just "nexus" so the path is simple
    mv nexus-3* nexus

    # Give the nexus user ownership of the Nexus files and data folder
    chown -R nexus:nexus /opt/nexus /opt/sonatype-work

    # Tell Nexus to run as the nexus user
    echo 'run_as_user="nexus"' > /opt/nexus/bin/nexus.rc

    # Red Hat has SELinux switched on, which blocks services from running
    # programs stored in /opt. This marks the Nexus start script as allowed.
    chcon -R -t bin_t /opt/nexus/bin

    # Create a service so Nexus starts automatically when the server reboots
    cat > /etc/systemd/system/nexus.service <<'SVC'
    [Unit]
    Description=Nexus Repository Manager
    After=network.target

    [Service]
    Type=forking
    LimitNOFILE=65536
    ExecStart=/opt/nexus/bin/nexus start
    ExecStop=/opt/nexus/bin/nexus stop
    User=nexus
    Restart=on-abort

    [Install]
    WantedBy=multi-user.target
    SVC

    # Start Nexus now and enable it on every boot
    systemctl daemon-reload
    systemctl enable nexus
    systemctl start nexus
  EOF

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

# ===============================================
# Ansible Server (public subnet 2)
# Runs the playbooks that build and deploy BankApp
# ===============================================
resource "aws_instance" "ansible_19thoct" {
  ami                         = data.aws_ami.redhat_19thoct.id
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public_subnet_2_19thoct.id
  vpc_security_group_ids      = [aws_security_group.ansible_sg_19thoct.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pair_19thoct.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y ansible-core git python3-pip
    hostnamectl set-hostname ansible-19thoct
    echo "preserve_hostname: true" > /etc/cloud/cloud.cfg.d/99_hostname.cfg
    sudo -u ec2-user ansible-galaxy collection install community.docker
  EOF

  tags = {
    Name    = "19thoct-ansible"
    Project = "19thoct"
  }
}

# ---------- Docker hosts (Kenneth) ----------

# The Docker hosts use the same Red Hat Enterprise Linux 9 image as Nexus
# (data "aws_ami" "redhat_19thoct" above), so every server runs one OS

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

    # Install the SSM agent (Red Hat images don't include it) so the team
    # can open a session through Session Manager without SSH
    retry dnf install -y https://s3.eu-west-3.amazonaws.com/amazon-ssm-eu-west-3/latest/linux_amd64/amazon-ssm-agent.rpm
    systemctl enable --now amazon-ssm-agent

    # Remove Red Hat's own container tools so they don't clash with Docker
    dnf remove -y podman buildah runc || true

    # Install Docker Engine from Docker's official Red Hat repository
    retry dnf install -y dnf-plugins-core
    retry dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
    retry dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

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

    # Folder for any persistent application data.
    # SELinux stays enforcing; mount this folder into containers with :Z
    # (for example -v /opt/bankapp/data:/data:Z) so SELinux allows access
    mkdir -p /opt/bankapp/data
    chown ec2-user:ec2-user /opt/bankapp/data

    # Only root and ec2-user (used by Ansible) can control Docker
    usermod -aG docker ec2-user

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

#creating m-node redhat instance
resource "aws_instance" "redhate_19thoct" {
  ami                         = data.aws_ami.redhat_19thoct.id
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public_subnet_2_19thoct.id
  vpc_security_group_ids      = [aws_security_group.ansible_sg_19thoct.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pair_19thoct.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name    = "19thoct-mnode"
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

# ==================================================
# JENKINS SERVER
# Private server for the BankApp CI/CD pipeline.
# ==================================================

resource "aws_instance" "jenkins_19thoct" {
  ami           = data.aws_ami.ubuntu_19thoct.id
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

    export DEBIAN_FRONTEND=noninteractive

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

    # Wait for Ubuntu's automatic updates to release the package lock.
    retry apt-get -o DPkg::Lock::Timeout=300 update

    # Install Java before installing Jenkins.
    # The JDK also provides the compiler needed for Java builds.
    retry apt-get -o DPkg::Lock::Timeout=300 install -y \
      ca-certificates \
      curl \
      fontconfig \
      openjdk-21-jdk \
      git \
      maven \
      unzip

    # Add the official Jenkins LTS repository signing key.
    install -d -m 0755 /etc/apt/keyrings

    retry curl -fsSL \
      https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
      -o /etc/apt/keyrings/jenkins-keyring.asc

    chmod 0644 /etc/apt/keyrings/jenkins-keyring.asc

    # Add the official Jenkins LTS package repository.
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
      > /etc/apt/sources.list.d/jenkins.list

    # Install Jenkins.
    retry apt-get -o DPkg::Lock::Timeout=300 update
    retry apt-get -o DPkg::Lock::Timeout=300 install -y jenkins

    # Start Jenkins now and automatically after reboot.
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