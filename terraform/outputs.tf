output "application_url" {
  description = "Public URL of the load-balanced web application"
  value       = "http://${module.compute.alb_dns_name}"
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.compute.alb_dns_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "autoscaling_group_name" {
  description = "Web tier Auto Scaling Group"
  value       = module.compute.asg_name
}

output "db_secret_arn" {
  description = "Secrets Manager ARN for the database credentials"
  value       = module.database.secret_arn
}

output "db_endpoint" {
  description = "RDS endpoint"
  value       = module.database.endpoint
  sensitive   = true
}
