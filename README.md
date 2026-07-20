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
Deployed  
CI/CD stable  
Infrastructure reproducible

## Future Enterprise Scaling

The current architecture serves a low-traffic personal portfolio but it is designed with future scalability in mind. If this API was transitioned to a production environment handling high concurrent traffic, I would implement the following upgrades:

### 1. High-Throughput & Cost Optimization (Read Path)
* **API Gateway Caching / DynamoDB Accelerator (DAX):** Instead of executing a database read query for every user checking load shedding schedules, I would implement an `aws_api_gateway_method_settings` caching layer with a TTL period. This would reduce DynamoDB read throughput costs by up to 80% during high-traffic spikes.

### 2. Traffic Shaving & Decoupling (Write Path)
* **Asynchronous Ingestion via Amazon SQS:** If thousands of IoT devices or users log an outage simultaneously, hitting the Lambda function directly could cause execution throttling. I would decouple the write path by placing an **Amazon SQS Queue** between API Gateway and Lambda to buffer incoming traffic and process logs smoothly.

### 3. Edge Security & Rate Limiting
* **AWS WAF (Web Application Firewall) Integration:** To protect the public endpoints from denial-of-service (DoS) attacks or automated scrapers, I would provision an `aws_wafv2_web_acl` resource in Terraform to enforce IP-based rate limiting.

### 4. GitOps & Multi-Environment Isolation
* **CI/CD Environments:** Expand the GitHub Actions pipeline to handle `staging` and `production` environments using distinct AWS accounts and Terraform workspace states. This would include adding an interactive manual approval gate in GitHub before applying changes to production infrastructure.


