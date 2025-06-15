# ==========================================
# Security Module Variables - infrastructure/terraform/modules/security/variables.tf
# ==========================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets"
  type        = list(string)
}