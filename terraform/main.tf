module "network" {
  source      = "./modules/network"
  app_name    = var.app_name
  aws_region  = var.aws_region
}

module "iam" {
  source       = "./modules/iam"
  app_name     = var.app_name
  github_repo  = var.github_repo
}

module "logs" {
  source   = "./modules/logs"
  app_name = var.app_name
}

module "alb" {
  source          = "./modules/alb"
  app_name        = var.app_name
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
}

module "ecs" {
  source              = "./modules/ecs"
  app_name            = var.app_name
  vpc_id              = module.network.vpc_id
  subnets             = module.network.public_subnets   # we’re using public for MVP
  alb_sg_id           = module.alb.alb_sg_id
  target_group_arn    = module.alb.tg_arn
  exec_role_arn       = module.iam.exec_role_arn
  ecr_image_uri       = var.ecr_repo_url
  log_group_name      = module.logs.log_group_name
  aws_region          = var.aws_region
}

output "alb_dns" {
  description = "Public URL"
  value       = module.alb.alb_dns
}
