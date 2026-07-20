output "api_gateway_invoke_url" {
  description = "The invoke URL of the API Gateway"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.outage_api.function_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.outage_logs.name
}
