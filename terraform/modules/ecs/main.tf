########################################
# Data source (account ID for SSM secrets)
########################################
data "aws_caller_identity" "current" {}

########################################
# ECS cluster
########################################
resource "aws_ecs_cluster" "cluster" {
  name = "${var.app_name}-cluster"
}

########################################
# Task definition
########################################
resource "aws_ecs_task_definition" "task" {
  family                   = "${var.app_name}-task"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.exec_role_arn

  container_definitions = jsonencode([
    {
      name  = "${var.app_name}"
      image = "${var.ecr_image_uri}:v15"
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

      environment = [
        {
          name  = "DB_HOST"
          value = var.db_host                  # RDS endpoint
        },
        {
          name  = "DB_NAME"
          value = "postgres"                   # default DB in RDS
        }
      ]

      secrets = [
        {
          name      = "DB_USERNAME"
          valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/cloud-cost-dashboard/db_username"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/cloud-cost-dashboard/db_password"
        }
      ]
    }
  ])
}

########################################
# ECS service
########################################
resource "aws_ecs_service" "service" {
  name            = "${var.app_name}-svc"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.app_name
    container_port   = 8000
  }
}
