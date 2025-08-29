output "state_bucket_name" {
  value       = var.backend_bucket_name
  description = "S3 bucket for Terraform state"
}

output "dynamodb_table_name" {
  value       = var.backend_table_name
  description = "DynamoDB table for state locking"
}

# VPC
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "IDs of public subnets"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "IDs of private subnets"
}

output "nat_gateway_id" {
  value       = module.vpc.nat_gateway_id
  description = "NAT Gateway ID"
}

# ECR
output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "ECR repository URL"
}

# EKS
output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}
