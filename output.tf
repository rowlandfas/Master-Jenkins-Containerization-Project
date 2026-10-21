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
