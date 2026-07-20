# South African Loadshedding Log API

Serverless AWS API for logging and retrieving loadshedding outage events in South Africa.  
Built with Terraform and deployed through GitHub Actions CI/CD.

## Why this project matters
This project demonstrates practical cloud engineering skills:
- Infrastructure as Code (Terraform)
- Serverless backend design (Lambda + API Gateway + DynamoDB)
- CI/CD automation in GitHub Actions
- Real-world production debugging and reliability improvements

## Tech Stack
- **AWS:** Lambda, API Gateway, DynamoDB, IAM  
- **IaC:** Terraform  
- **CI/CD:** GitHub Actions  
- **Runtime:** Python 3.11  

## What it does
- `POST /log-outage` — create outage records  
- `GET /outages` — fetch outage records  

## Architecture (high level)
Client → API Gateway → Lambda → DynamoDB

## CI/CD
On push to `main`, pipeline:
1. Packages Lambda zip
2. Runs Terraform init/validate/plan/apply
3. Imports existing AWS resources into Terraform state when needed

## Key engineering wins
- Solved Terraform state drift for pre-existing AWS resources
- Fixed Lambda permission conflict (“statement id already exists”)
- Fixed missing Lambda artifact issue in ephemeral CI runners
- Resolved GitHub Actions YAML parse failure (`Line 1, Col 7`)

## Status
✅ Deployed  
✅ CI/CD stable  
✅ Infrastructure reproducible
