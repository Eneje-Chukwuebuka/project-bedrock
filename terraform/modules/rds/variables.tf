variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for RDS instances"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "EKS cluster security group ID to allow DB access"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "mysql_db_name" {
  description = "MySQL database name"
  type        = string
}

variable "postgres_db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}