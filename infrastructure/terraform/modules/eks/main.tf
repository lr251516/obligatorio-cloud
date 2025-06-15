# ==========================================
# EKS Module - infrastructure/terraform/modules/eks/main.tf
# ==========================================

# Data sources para rol LabRole
data "aws_iam_role" "cluster_service_role" {
  name = "LabRole"
}

data "aws_iam_role" "node_group_role" {
  name = "LabRole"
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = data.aws_iam_role.cluster_service_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [var.control_plane_security_group_id]
  }

  tags = {
    Name = var.cluster_name
  }
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-workers"
  node_role_arn   = data.aws_iam_role.node_group_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_capacity
    min_size     = var.min_capacity
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = var.instance_types

  tags = {
    Name = "${var.project_name}-workers"
  }
}