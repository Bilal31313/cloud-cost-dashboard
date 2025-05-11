variable "app_name" { type = string }
variable "vpc_id" { type = string }
variable "subnets" { type = list(string) }
variable "alb_sg_id" { type = string }
variable "target_group_arn" { type = string }
variable "exec_role_arn" { type = string }
variable "ecr_image_uri" { type = string }
variable "log_group_name" { type = string }
variable "aws_region" { type = string }
variable "db_host" {
  description = "RDS endpoint for PostgreSQL connection"
  type        = string
}
variable "ecs_sg_id" {
  description = "Security group ID used by ECS tasks"
  type        = string
}
