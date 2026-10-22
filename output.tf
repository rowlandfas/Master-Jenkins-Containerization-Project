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

# Public IP of the Ansible server - we use this to reach it through the internet
output "ansible_public_ip" {
  value = aws_instance.ansible_19thoct.public_ip
}

output "ansible_private_ip" {
  value = aws_instance.ansible_19thoct.private_ip
} 
