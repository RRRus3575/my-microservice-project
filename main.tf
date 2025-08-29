variable "backend_bucket_name" {
description = "Globally-unique S3 bucket name for Terraform state"
type = string
}

variable "aws_region" {
  description = "Region for all AWS resources except S3/DynamoDB backend"
  type        = string
  default     = "us-west-2"
}

provider "aws" {
  region = var.aws_region
}


variable "backend_table_name" {
description = "DynamoDB table name for Terraform state locking"
type = string
default = "terraform-locks"
}


variable "vpc_name" {
description = "Name tag for the VPC"
type = string
default = "lesson-5-vpc"
}


variable "vpc_cidr_block" {
type = string
default = "10.0.0.0/16"
}


variable "availability_zones" {
description = "Three AZs for subnets"
type = list(string)
default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}


variable "public_subnets" {
type = list(string)
default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}


variable "private_subnets" {
type = list(string)
default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}


variable "ecr_name" {
type = string
default = "lesson-5-ecr"
}


variable "scan_on_push" {
type = bool
default = true
}



# module "s3_backend" {
# source = "./modules/s3-backend"
# bucket_name = var.backend_bucket_name
# table_name = var.backend_table_name
# }

# module "s3_backend_west" {
#   source      = "./modules/s3-backend"
#   bucket_name = "my-tfstate-3575857895123-lesson-5-west" 
#   table_name  = "terraform-locks-west"
# }



module "vpc" {
source = "./modules/vpc"
vpc_cidr_block = var.vpc_cidr_block
public_subnets = var.public_subnets
private_subnets = var.private_subnets
availability_zones = var.availability_zones
vpc_name = var.vpc_name
}



module "ecr" {
source = "./modules/ecr"
ecr_name = var.ecr_name
scan_on_push = var.scan_on_push
}



module "eks" {
  source              = "./modules/eks"
  cluster_name        = "lesson-7-ecr-rus01"
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  node_instance_types = ["t3.small"]
  desired_size        = 2
  min_size            = 2
  max_size            = 6
}


output "ecr_repo_url" {
  value       = module.ecr.repository_url
  description = "ECR repository URL"
}

