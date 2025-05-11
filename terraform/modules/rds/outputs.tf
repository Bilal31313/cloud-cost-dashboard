output "rds_endpoint" {
  description = "The RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgres.endpoint
}
