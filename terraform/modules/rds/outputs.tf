output "mysql_endpoint" {
  description = "MySQL RDS endpoint"
  value       = aws_db_instance.mysql.address
}

output "postgres_endpoint" {
  description = "PostgreSQL RDS endpoint"
  value       = aws_db_instance.postgres.address
}

output "mysql_secret_arn" {
  description = "ARN of MySQL credentials secret"
  value       = aws_secretsmanager_secret.mysql.arn
}

output "postgres_secret_arn" {
  description = "ARN of PostgreSQL credentials secret"
  value       = aws_secretsmanager_secret.postgres.arn
}

output "rds_security_group_id" {
  description = "Security group ID for RDS instances"
  value       = aws_security_group.rds.id
}