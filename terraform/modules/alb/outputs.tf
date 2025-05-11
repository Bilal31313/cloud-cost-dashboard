output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "tg_arn" {
  value = aws_lb_target_group.tg.arn
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
