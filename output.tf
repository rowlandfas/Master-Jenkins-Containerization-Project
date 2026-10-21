output "vpc_id" {
  description = "ID of the 19thoct VPC"
  value       = aws_vpc.vpc_19thoct.id
}

output "vpc_cidr" {
  description = "IPv4 address range of the 19thoct VPC"
  value       = aws_vpc.vpc_19thoct.cidr_block
}