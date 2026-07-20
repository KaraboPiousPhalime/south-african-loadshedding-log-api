terraform {
  backend "s3" {
    bucket         = "tfstate-south-african-loadshedding-log-api"
    key            = "prod/terraform.tfstate"
    region         = "af-south-1"
    dynamodb_table = "tfstate-locks-south-african-loadshedding-log-api"
    encrypt        = true
  }
}
