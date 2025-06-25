# ==========================================
# Bastion Module - infrastructure/terraform/modules/bastion/main.tf
# ==========================================

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-bastion"
  vpc_id      = var.vpc_id
  description = "Security group for bastion host"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

# Bastion Host Instance
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  # Networking
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  # User data for initial config
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    mysql_host = var.mysql_host
  }))

  tags = {
    Name = "${var.project_name}-bastion-host"
    Type = "Bastion"
  }
}

# ==========================================
# SECURITY GROUP RULE PARA RDS
# ==========================================

# Permitir conexión desde bastion a RDS
resource "aws_security_group_rule" "rds_from_bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = var.rds_security_group_id
  description              = "MySQL access from bastion host"
}