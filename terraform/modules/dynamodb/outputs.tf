output "carts_table_name" {
  description = "Name of the carts DynamoDB table"
  value       = aws_dynamodb_table.carts.name
}

output "orders_table_name" {
  description = "Name of the orders DynamoDB table"
  value       = aws_dynamodb_table.orders.name
}

output "carts_table_arn" {
  description = "ARN of the carts DynamoDB table"
  value       = aws_dynamodb_table.carts.arn
}

output "orders_table_arn" {
  description = "ARN of the orders DynamoDB table"
  value       = aws_dynamodb_table.orders.arn
}