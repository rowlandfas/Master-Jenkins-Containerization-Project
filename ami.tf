

# 1.Wait for initial Docker installation
resource "time_sleep" "wait_for_docker_setup_19thoct" {
  depends_on = [
    aws_instance.docker_hosts_lt_19thoct
  ]

  create_duration = "300s"
}

# 3. Create the custom Docker AMI
resource "aws_ami_from_instance" "docker_ami_19thoct" {
  name = "19thoct-docker-host-ami"

  source_instance_id = aws_instance.docker_hosts_lt_19thoct.id

  depends_on = [
    time_sleep.wait_for_docker_setup_19thoct
  ]

  tags = {
    Name    = "19thoct-docker-host-ami"
    Project = "19thoct"
  }
}

