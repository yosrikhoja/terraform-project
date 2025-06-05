output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "lambda_name" {
  value = aws_lambda_function.rds_exporter.function_name
}
