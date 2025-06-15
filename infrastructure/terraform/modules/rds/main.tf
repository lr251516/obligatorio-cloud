# ==========================================
# RDS Module Main - infrastructure/terraform/modules/rds/main.tf
# ==========================================

# Random password para la base de datos
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# RDS MySQL Multi-AZ
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-mysql"

  # Engine configuration
  engine                = "mysql"
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database configuration
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  # Network configuration
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false

  # High Availability
  multi_az = true

  # Backup configuration
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # Monitoring
  monitoring_interval = 0

  # Performance insights
  performance_insights_enabled = true

  # Deletion protection
  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-mysql"
  }
}

