module "network" {
  source     = "./modules/network"
  app_name   = var.app_name
  aws_region = var.aws_region
}

module "iam" {
  source      = "./modules/iam"
  app_name    = var.app_name
  github_repo = "Bilal31313/cloud-cost-dashboard"
}

module "logs" {
  source   = "./modules/logs"
  app_name = var.app_name
}

module "alb" {
  source         = "./modules/alb"
  app_name       = var.app_name
  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnets
}
resource "aws_security_group" "ecs_sg" {
  name        = "${var.app_name}-ecs-sg"
  description = "Allow traffic from ALB to ECS tasks"
  vpc_id      = module.network.vpc_id

  ingress {
    description     = "ALB ECS (HTTP)"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [module.alb.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ecs-sg"
  }
}
module "ecs" {
  source           = "./modules/ecs"
  app_name         = var.app_name
  vpc_id           = module.network.vpc_id
  subnets          = module.network.public_subnets # we’re using public for MVP
  alb_sg_id        = module.alb.alb_sg_id
  target_group_arn = module.alb.tg_arn
  exec_role_arn    = module.iam.exec_role_arn
  ecr_image_uri    = var.ecr_repo_url
  log_group_name   = module.logs.log_group_name
  aws_region       = var.aws_region
  db_host             = module.rds.rds_endpoint
   ecs_sg_id = aws_security_group.ecs_sg.id
}

output "alb_dns" {
  description = "Public URL"
  value       = module.alb.alb_dns
}
module "rds" {
  source                = "./modules/rds"
  db_identifier         = "${var.app_name}-db"
  db_name               = "costs"
  db_username           = "postgres"                   # replace with TF var / secret later
  db_password           = "supersecurepassword123"     # replace with TF var / secret later
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.private_subnet_ids
  ecs_security_group_id = aws_security_group.ecs_sg.id # ✅ break the cycle
}
