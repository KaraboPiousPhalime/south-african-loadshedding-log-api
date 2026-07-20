terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# DynamoDB Table
resource "aws_dynamodb_table" "outage_logs" {
  name           = "OutageLogs"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LogID"

  attribute {
    name = "LogID"
    type = "S"
  }

  tags = {
    Environment = "production"
    Project     = "OutageLogAPI"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "outage-api-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda to access DynamoDB
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name   = "lambda-dynamodb-policy"
  role   = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.outage_logs.arn
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "outage_api" {
  filename      = "lambda_function.zip"
  function_name = "OutageLogAPI"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 128

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.outage_logs.name
    }
  }

  depends_on = [aws_iam_role_policy.lambda_dynamodb_policy]
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "outage_api" {
  name        = "OutageLogAPI"
  description = "API for logging South African loadshedding outages"
}

# /log-outage Resource
resource "aws_api_gateway_resource" "log_outage" {
  rest_api_id = aws_api_gateway_rest_api.outage_api.id
  parent_id   = aws_api_gateway_rest_api.outage_api.root_resource_id
  path_part   = "log-outage"
}

# /outages Resource
resource "aws_api_gateway_resource" "outages" {
  rest_api_id = aws_api_gateway_rest_api.outage_api.id
  parent_id   = aws_api_gateway_rest_api.outage_api.root_resource_id
  path_part   = "outages"
}

# POST /log-outage Method
resource "aws_api_gateway_method" "log_outage_post" {
  rest_api_id      = aws_api_gateway_rest_api.outage_api.id
  resource_id      = aws_api_gateway_resource.log_outage.id
  http_method      = "POST"
  authorization    = "NONE"
}

# GET /outages Method
resource "aws_api_gateway_method" "outages_get" {
  rest_api_id      = aws_api_gateway_rest_api.outage_api.id
  resource_id      = aws_api_gateway_resource.outages.id
  http_method      = "GET"
  authorization    = "NONE"
}

# POST /log-outage Integration
resource "aws_api_gateway_integration" "log_outage_integration" {
  rest_api_id             = aws_api_gateway_rest_api.outage_api.id
  resource_id             = aws_api_gateway_resource.log_outage.id
  http_method             = aws_api_gateway_method.log_outage_post.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.outage_api.invoke_arn
}

# GET /outages Integration
resource "aws_api_gateway_integration" "outages_integration" {
  rest_api_id             = aws_api_gateway_rest_api.outage_api.id
  resource_id             = aws_api_gateway_resource.outages.id
  http_method             = aws_api_gateway_method.outages_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.outage_api.invoke_arn
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.outage_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.outage_api.execution_arn}/*/*"
}

# Deployment
resource "aws_api_gateway_deployment" "outage_api" {
  rest_api_id = aws_api_gateway_rest_api.outage_api.id
  depends_on = [
    aws_api_gateway_integration.log_outage_integration,
    aws_api_gateway_integration.outages_integration
  ]
}

# Stage
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.outage_api.id
  rest_api_id   = aws_api_gateway_rest_api.outage_api.id
  stage_name    = "prod"
}
