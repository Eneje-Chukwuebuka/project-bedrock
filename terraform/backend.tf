terraform {
  backend "s3" {
    bucket       = "bedrock-tfstate-dibia-2026"
    key          = "project-bedrock/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
