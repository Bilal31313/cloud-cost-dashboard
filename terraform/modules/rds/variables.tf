variable "db_identifier" {
  description = "Unique identifier for the RDS instance"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "db_username" {
  description = "Master username for the DB"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for the DB"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID for the RDS instance"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for RDS"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID of the ECS tasks that need DB access"
  type        = string
}
