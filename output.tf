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
# ---------- Docker host outputs (Kenneth) ----------
output "docker_hosts_asg_name" {
  description = "Name of the Docker hosts auto scaling group"
  value       = aws_autoscaling_group.docker_hosts_asg_19thoct.name
}

output "docker_hosts_sg_id" {
  description = "Security group ID of the Docker hosts"
  value       = aws_security_group.docker_hosts_sg_19thoct.id
}

output "jenkins_instance_id" {
  description = "ID of the 19thoct Jenkins server"
  value       = aws_instance.jenkins_19thoct.id
}

output "jenkins_private_ip" {
  description = "Private IP address of the Jenkins server"
  value       = aws_instance.jenkins_19thoct.private_ip
}

output "jenkins_private_url" {
  description = "Internal Jenkins URL, accessible through private connectivity"
  value       = "http://${aws_instance.jenkins_19thoct.private_ip}:8080"
}

output "sonarqube_url" {
  description = "SonarQube HTTPS URL accessible through private networking"
  value       = "https://${aws_route53_record.sonarqube_19thoct.fqdn}"
}

output "sonarqube_alb_dns_name" {
  description = "Internal SonarQube ALB DNS name"
  value       = aws_lb.sonarqube_19thoct.dns_name
}
# ---------- BankApp domain outputs (Kenneth) ----------
output "bankapp_url" {
  description = "Public HTTPS address of the BankApp"
  value       = "https://${aws_route53_record.bankapp_19thoct.fqdn}"
}

output "bankapp_alb_dns_name" {
  description = "AWS DNS name of the BankApp load balancer"
  value       = aws_lb.bankapp_19thoct.dns_name
}
