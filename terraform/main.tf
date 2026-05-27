terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# ─── VPC MODULE ─────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  tags                 = var.tags
}

# ─── EKS MODULE ─────────────────────────────────────────
module "eks" {
  source = "./modules/eks"

  project_name       = var.project_name
  cluster_version    = var.eks_cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  node_instance_type = var.eks_node_instance_type
  node_desired_size  = var.eks_node_desired_size
  node_min_size      = var.eks_node_min_size
  node_max_size      = var.eks_node_max_size
  tags               = var.tags
}

# ─── RDS MODULE ─────────────────────────────────────────
module "rds" {
  source = "./modules/rds"

  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  eks_security_group_id = module.eks.cluster_security_group_id
  instance_class        = var.rds_instance_class
  mysql_db_name         = var.rds_mysql_db_name
  postgres_db_name      = var.rds_postgres_db_name
  tags                  = var.tags
}

# ─── DYNAMODB MODULE ────────────────────────────────────
module "dynamodb" {
  source = "./modules/dynamodb"

  project_name = var.project_name
  tags         = var.tags
}

# ─── S3 + LAMBDA MODULE ─────────────────────────────────
module "s3_lambda" {
  source = "./modules/s3-lambda"

  project_name = var.project_name
  student_id   = var.student_id
  tags         = var.tags
}