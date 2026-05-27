terraform {
    backend "s3" {
    bucket         = "project-bedrock-tfstate-394747153553"
    key            = "project-bedrock/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "project-bedrock-tfstate-lock"
    encrypt        = true
  }
}