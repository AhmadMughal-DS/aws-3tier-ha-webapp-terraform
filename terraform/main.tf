locals {
  name_prefix = var.project_name
}

module "network" {
  source      = "./modules/network"
  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
  az_count    = 2
}

module "security" {
  source      = "./modules/security"
  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id
}

module "compute" {
  source            = "./modules/compute"
  name_prefix       = local.name_prefix
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  app_subnet_ids    = module.network.app_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
  web_sg_id         = module.security.web_sg_id
  instance_type     = var.instance_type
  asg_min           = var.asg_min
  asg_max           = var.asg_max
  asg_desired       = var.asg_desired
  certificate_arn   = var.certificate_arn
}

module "database" {
  source         = "./modules/database"
  name_prefix    = local.name_prefix
  environment    = var.environment
  db_subnet_ids  = module.network.db_subnet_ids
  db_sg_id       = module.security.db_sg_id
  instance_class = var.db_instance_class
  db_name        = var.db_name
  db_username    = var.db_username
  multi_az       = var.db_multi_az
}
