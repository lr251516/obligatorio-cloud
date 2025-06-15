# ==========================================
# RDS Module Outputs - infrastructure/terraform/modules/rds/outputs.tf
# ==========================================

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Database username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.main.port
}

output "db_password" {
  description = "Database password"
  value       = random_password.db_password.result
  sensitive   = true
}