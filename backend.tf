terraform {
  backend "s3" {
    bucket         = "auto-guard-tf-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "auto-guard-tf-lock"
  }
}