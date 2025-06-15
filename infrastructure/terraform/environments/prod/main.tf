# ==========================================
# PRODUCTION ENVIRONMENT
# ==========================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ==========================================
# VPC MODULE
# ==========================================

module "vpc" {
  source = "../../modules/vpc"

  project_name          = var.project_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
}

# ==========================================
# SECURITY MODULE
# ==========================================

module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = module.vpc.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ==========================================
# EKS MODULE
# ==========================================

module "eks" {
  source = "../../modules/eks"

  project_name                    = var.project_name
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  private_subnet_ids              = module.vpc.private_subnet_ids
  control_plane_security_group_id = module.security.eks_control_plane_security_group_id

  # Node group configuration
  instance_types   = var.instance_types
  desired_capacity = var.desired_capacity
  max_capacity     = var.max_capacity
  min_capacity     = var.min_capacity

  depends_on = [module.vpc, module.security]
}

# ==========================================
# RDS MODULE
# ==========================================

module "rds" {
  source = "../../modules/rds"

  project_name         = var.project_name
  db_subnet_group_name = module.vpc.database_subnet_group_name
  security_group_id    = module.security.rds_security_group_id

  # Database configuration
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  db_name           = var.db_name
  db_username       = var.db_username

  depends_on = [module.vpc, module.security]
}