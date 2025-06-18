# ==========================================
# EKS Module Variables - infrastructure/terraform/modules/eks/variables.tf
# ==========================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.33"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "control_plane_security_group_id" {
  description = "Security group ID for EKS control plane"
  type        = string
}

variable "instance_types" {
  description = "Instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "max_capacity" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 6
}

variable "min_capacity" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}