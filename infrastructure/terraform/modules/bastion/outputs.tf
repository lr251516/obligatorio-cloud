# ==========================================
# Bastion Module Outputs - infrastructure/terraform/modules/bastion/outputs.tf
# ==========================================

output "bastion_instance_id" {
  description = "ID of the bastion host instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP address of the bastion host"
  value       = aws_instance.bastion.private_ip
}

output "bastion_security_group_id" {
  description = "Security group ID of the bastion host"
  value       = aws_security_group.bastion.id
}

output "ssh_connection_command" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.bastion.public_ip}"
}

output "mysql_tunnel_command" {
  description = "SSH tunnel command for MySQL access"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem -L 3306:${var.mysql_host}:3306 ec2-user@${aws_instance.bastion.public_ip}"
}