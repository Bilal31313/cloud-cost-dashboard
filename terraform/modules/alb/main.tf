resource "aws_security_group" "alb_sg" { … }          # unchanged

resource "aws_lb" "alb" { … }                         # unchanged

resource "aws_lb_target_group" "tg" {
  name     = "${var.app_name}-tg"
  port     = 8000           # <── changed
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/costs"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80              # ALB still listens on :80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
