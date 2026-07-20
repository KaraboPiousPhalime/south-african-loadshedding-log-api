# Terraform Outage API

Infrastructure and backend for the Outage Logging API on AWS.

## What this deploys
- API Gateway (REST) with:
  - POST /log-outage
  - GET /outages
- Lambda function (Python)
- DynamoDB table (OutageLogs)

## Prerequisites
- Terraform installed
- AWS credentials configured in ~/.aws/credentials

## Deploy
terraform init
terraform validate
terraform plan
terraform apply
