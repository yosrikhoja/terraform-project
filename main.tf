terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"
}
module "networking" {
  source = "./modules/networking"
}
module "backend_rds_lambda" {
  source            = "./modules/backend_rds_lambda/main.tf"
  vpc_id            = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  db_username       = var.db_username
  db_password       = var.db_password
}

module "backend" {
  source            = "./modules/backend/main.tf"
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  db_endpoint       = module.backend_rds_lambda.db_endpoint
}

module "frontend" {
  source            = "./modules/frontend/main.tf"
  public_subnet_ids = module.networking.public_subnet_ids
}