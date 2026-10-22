output "vpc_id" {
  description = "ID of the 19thoct VPC"
  value       = aws_vpc.vpc_19thoct.id
}

output "vpc_cidr" {
  description = "IPv4 address range of the 19thoct VPC"
  value       = aws_vpc.vpc_19thoct.cidr_block
}

# ---------- Subnet outputs (Kenneth) ----------
output "public_subnet_ids" {
  description = "IDs of the 19thoct public subnets"
  value       = [aws_subnet.public_subnet_1_19thoct.id, aws_subnet.public_subnet_2_19thoct.id]
}

output "private_subnet_ids" {
  description = "IDs of the 19thoct private subnets"
  value       = [aws_subnet.private_subnet_1_19thoct.id, aws_subnet.private_subnet_2_19thoct.id]
}

# Private IP of the Nexus server - we use this to reach it through the bastion
output "nexus_private_ip" {
  value = aws_instance.nexus_19thoct.private_ip
}

# ---------- Docker host outputs (Kenneth) ----------
output "docker_hosts_asg_name" {
  description = "Name of the Docker hosts auto scaling group"
  value       = aws_autoscaling_group.docker_hosts_asg_19thoct.name
}

output "docker_hosts_sg_id" {
  description = "Security group ID of the Docker hosts"
  value       = aws_security_group.docker_hosts_sg_19thoct.id
}
