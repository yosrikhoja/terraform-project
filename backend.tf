    terraform {
    backend "s3" {
        bucket = "terraform-state-bucket-01"
        key    = "terraform-state-bucket-01.terraform.tfstate"
        region = "us-east-1" 
    }
    }
