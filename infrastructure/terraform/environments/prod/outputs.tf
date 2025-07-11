# ==========================================
# PRODUCTION OUTPUTS
# ==========================================

# ==========================================
# AWS OUTPUTS
# ==========================================

data "aws_caller_identity" "current" {}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

# ==========================================
# VPC OUTPUTS
# ==========================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = module.vpc.database_subnet_ids
}

# ==========================================
# SECURITY OUTPUTS
# ==========================================

output "clb_security_group_id" {
  description = "ID of the CLB security group"
  value       = module.security.clb_security_group_id
}

output "eks_nodes_security_group_id" {
  description = "ID of the EKS nodes security group"
  value       = module.security.eks_nodes_security_group_id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = module.security.rds_security_group_id
}

# ==========================================
# EKS OUTPUTS
# ==========================================

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.cluster_name
}

output "cluster_version" {
  description = "Version of the EKS cluster"
  value       = module.eks.cluster_version
}

# ==========================================
# RDS OUTPUTS
# ==========================================

output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
}

output "db_name" {
  description = "Database name"
  value       = module.rds.db_name
}

output "db_port" {
  description = "Database port"
  value       = module.rds.db_port
}

# ==========================================
# BASTION OUTPUTS
# ==========================================

output "bastion_public_ip" {
  description = "Public IP of bastion host"
  value       = module.bastion.bastion_public_ip
}

output "bastion_ssh_command" {
  description = "SSH command to connect to bastion"
  value       = module.bastion.ssh_connection_command
}

output "mysql_tunnel_command" {
  description = "SSH tunnel command for MySQL"
  value       = module.bastion.mysql_tunnel_command
}