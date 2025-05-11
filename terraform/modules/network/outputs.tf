output "vpc_id" { value = aws_vpc.this.id }
output "public_subnets" { value = aws_subnet.public[*].id }
output "private_subnet_ids" {
  description = "IDs of private subnets for RDS"
  value       = aws_subnet.private[*].id     
}
