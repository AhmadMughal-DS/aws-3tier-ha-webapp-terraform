output "endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.this.endpoint
  sensitive   = true
}

output "secret_arn" {
  description = "Secrets Manager ARN holding the DB credentials"
  value       = aws_secretsmanager_secret.db.arn
}
