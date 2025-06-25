# ==========================================
# Bastion Module Variables - infrastructure/terraform/modules/bastion/variables.tf
# ==========================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet for bastion host"
  type        = string
}

variable "rds_security_group_id" {
  description = "Security group ID of RDS instance"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair for SSH access"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "mysql_host" {
  description = "RDS MySQL hostname for bastion configuration"
  type        = string
  default     = ""
}