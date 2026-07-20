# South African Loadshedding Log API

A serverless AWS API for logging and retrieving loadshedding outage reports in South Africa.  
Infrastructure is managed with Terraform and deployed automatically using GitHub Actions.

---

## Features

- Log outage events via API
- Retrieve outage records
- Fully serverless architecture
- Infrastructure as Code (Terraform)
- CI/CD pipeline for automated deployments

---

## Tech Stack

- **Cloud:** AWS
  - Lambda
  - API Gateway (REST API)
  - DynamoDB
  - IAM
- **Infrastructure as Code:** Terraform
- **CI/CD:** GitHub Actions
- **Runtime:** Python 3.11 (AWS Lambda)

---

## Architecture

1. Client sends request to API Gateway endpoint.
2. API Gateway invokes the Lambda function.
3. Lambda writes to / reads from DynamoDB.
4. Terraform provisions and updates all resources.
5. GitHub Actions runs deployment pipeline on push to `main`.

---

## API Endpoints

- `POST /log-outage`  
  Logs a new outage event.

- `GET /outages`  
  Returns stored outage records.

---

## Project Structure

```text
.
├── .github/workflows/deploy.yml
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── lambda_function.py
├── requirements.txt
└── README.md
```

---

## CI/CD Workflow

On each push to `main`, GitHub Actions:

1. Checks out repository
2. Sets up Terraform
3. Packages Lambda source into `lambda_function.zip`
4. Runs `terraform init -reconfigure`
5. Imports existing AWS resources into state if missing:
   - DynamoDB table
   - IAM role
   - Lambda function
   - Lambda permission
6. Runs:
   - `terraform validate`
   - `terraform plan`
   - `terraform apply -auto-approve`

---

## Key Engineering Challenges Solved

- **Terraform state drift in CI**  
  Resolved conflicts when AWS resources already existed but were missing from Terraform state.

- **Resource conflict errors**  
  Handled `EntityAlreadyExists` / `ResourceConflictException` by using idempotent import logic in pipeline.

- **Lambda permission conflict**  
  Fixed “statement id already exists” by importing existing Lambda permission into Terraform state.

- **Missing Lambda artifact in runner**  
  Fixed “zip not found” by packaging Lambda during workflow execution.

- **Workflow syntax failure in CI**  
  Resolved GitHub Actions YAML parsing error (`Line 1, Col 7: A sequence was not expected`) by correcting workflow structure and indentation.

---

## Local Development

### Prerequisites

- Terraform installed
- AWS credentials configured
- Python 3.11 (for Lambda code editing/testing)

### Deploy manually

```bash
terraform init -reconfigure
terraform validate
terraform plan
terraform apply
```

---

## Outputs

Typical outputs include:
- API Gateway invoke URL
- DynamoDB table name
- Lambda function name

---

## Status

✅ CI/CD deployment pipeline operational  
✅ Infrastructure provisioning stable  
✅ Existing AWS resources reconciled with Terraform state  
✅ Workflow syntax and state/import issues resolved
