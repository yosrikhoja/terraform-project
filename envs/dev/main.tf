# envs/dev/main.tf
module "networking" {
  source = "../modules/networking"
  cidr_block = "10.0.0.0/16"
}

module "frontend" {
  source = "../modules/frontend"
  hosted_zone_id = "Z123456789EXAMPLE"
}

module "backend" {
  source = "../modules/backend"
}