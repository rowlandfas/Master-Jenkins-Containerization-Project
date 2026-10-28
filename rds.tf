# =========================================================
# CT-13: Multi-AZ RDS MySQL database for BankApp
# Multi-AZ DB instance: one primary + one synchronous standby
# in a second AZ. The standby is NOT readable; it exists for
# automatic failover only.
# =========================================================

resource "aws_db_instance" "bankapp_db_19thoct" {
  identifier     = "19thoct-bankapp-db"
  engine         = "mysql"
  engine_version = "8.4"
  instance_class = var.db_instance_class

  db_name  = "bankapp"
  username = "bankadmin"

  # AWS generates the password and stores it in Secrets Manager.
  # It never appears in code, variables or plan output.
  manage_master_user_password = true

  # High availability
  multi_az             = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group_19thoct.name

  # Private access only, from the application security group
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg_19thoct.id]
  port                   = 3306

  # Storage
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  # Backups: daily snapshot + transaction logs for point-in-time restore
  backup_retention_period = 7
  backup_window           = "01:00-02:00"
  maintenance_window      = "sun:03:00-sun:04:00"
  copy_tags_to_snapshot   = true

  # Logs to CloudWatch for troubleshooting
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]

  auto_minor_version_upgrade = true

  # Training settings so the nightly destroy works.
  # For production: deletion_protection = true, skip_final_snapshot = false
  deletion_protection = false
  skip_final_snapshot = true
  apply_immediately   = true

  tags = {
    Name    = "19thoct-bankapp-db"
    Project = "19thoct"
  }
}

# Let the Docker hosts read the database secret, and nothing else
resource "aws_iam_role_policy" "docker_hosts_read_db_secret_19thoct" {
  name = "19thoct-read-db-secret"
  role = aws_iam_role.docker_hosts_role_19thoct.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_db_instance.bankapp_db_19thoct.master_user_secret[0].secret_arn
    }]
  })
}

variable "db_instance_class" {
  description = "RDS instance size for the BankApp database"
  type        = string
  default     = "db.t3.micro"
}

output "rds_endpoint" {
  description = "Hostname the BankApp uses to connect to MySQL"
  value       = aws_db_instance.bankapp_db_19thoct.address
}

output "rds_secret_arn" {
  description = "Secrets Manager ARN holding the database username and password"
  value       = aws_db_instance.bankapp_db_19thoct.master_user_secret[0].secret_arn
}
