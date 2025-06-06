output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "lambda_name" {
  value = aws_lambda_function.rds_exporter.function_name
}
output "lambda_arn" {
  value = aws_lambda_function.db_reader.arn
}

output "db_endpoint" {
  value = aws_db_instance.default.endpoint
}