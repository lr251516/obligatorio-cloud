# ==========================================
# Security Module Outputs - infrastructure/terraform/modules/security/outputs.tf
# ==========================================

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "eks_control_plane_security_group_id" {
  description = "ID of the EKS control plane security group"
  value       = aws_security_group.eks_control_plane.id
}

output "eks_nodes_security_group_id" {
  description = "ID of the EKS nodes security group"
  value       = aws_security_group.eks_nodes.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}