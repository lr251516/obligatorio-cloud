# ==========================================
# VPC Module Outputs - infrastructure/terraform/modules/vpc/outputs.tf
# ==========================================

output "vpc_id" {
  value = aws_vpc.main-vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.main-vpc.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  value = aws_subnet.database[*].id
}

output "database_subnet_group_name" {
  value = aws_db_subnet_group.main.name
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main-igw.id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.nat-gw[*].id
}