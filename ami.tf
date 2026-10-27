
# ===============================================
# CT-21: Base Docker host -> wait -> AMI
# ===============================================

# 1. Create the base Docker server
resource "aws_instance" "docker_base_19thoct" {
  ami           = data.aws_ami.redhat_19thoct.id
  instance_type = "t3.small"

  subnet_id = aws_subnet.private_subnet_1_19thoct.id

  vpc_security_group_ids = [
    aws_security_group.docker_hosts_sg_19thoct.id
  ]

  key_name = aws_key_pair.key_pair_19thoct.key_name

  iam_instance_profile = aws_iam_instance_profile.docker_hosts_profile_19thoct.name

  user_data = file("${path.module}/docker-host-userdata.sh")

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name    = "19thoct-docker-base"
    Project = "19thoct"
  }
}

# 2. Wait for initial Docker installation
resource "time_sleep" "wait_for_docker_setup_19thoct" {
  depends_on = [
    aws_instance.docker_base_19thoct
  ]

  create_duration = "300s"
}

# 3. Create the custom Docker AMI
resource "aws_ami_from_instance" "docker_ami_19thoct" {
  name = "19thoct-docker-host-ami"

  source_instance_id = aws_instance.docker_base_19thoct.id

  depends_on = [
    time_sleep.wait_for_docker_setup_19thoct
  ]

  tags = {
    Name    = "19thoct-docker-host-ami"
    Project = "19thoct"
  }
}

