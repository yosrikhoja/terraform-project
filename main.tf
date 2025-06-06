
module "networking" {
  source = "./modules/networking"
}
module "backend_rds_lambda" {
  source            = "./modules/backend_rds_lambda"
  vpc_id            = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  subnet_ids        = module.networking.private_subnet_ids
  db_username       = var.db_username
  db_password       = var.db_password
  s3_bucket_name    = var.s3_bucket_name
}

module "backend" {
  source            = "./modules/backend"
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  db_endpoint       = module.backend_rds_lambda.db_endpoint
  ami_id            = var.ami_id
}

module "frontend" {
  source            = "./modules/frontend"
  public_subnet_ids = module.networking.public_subnet_ids
}