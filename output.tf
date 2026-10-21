# ---------- Subnet outputs (Kenneth) ----------
output "public_subnet_ids" {
  value = [aws_subnet.oct2026_public_subnet_1.id, aws_subnet.oct2026_public_subnet_2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.oct2026_private_subnet_1.id, aws_subnet.oct2026_private_subnet_2.id]
}
