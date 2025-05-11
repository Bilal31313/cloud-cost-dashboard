# … existing ecs_sg & cluster unchanged …

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.app_name}-task"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.exec_role_arn

  container_definitions = jsonencode([{
    name  = "${var.app_name}"
    image = "${var.ecr_image_uri}:latest"
    portMappings = [{
      containerPort = 8000   # <── changed
      hostPort      = 8000   # <── changed
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.log_group_name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "service" {
  name            = "${var.app_name}-svc"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.app_name}"
    container_port   = 8000   # <── changed
  }
}
