output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.web.name
}

output "access_logs_bucket" {
  description = "S3 bucket holding ALB access logs"
  value       = aws_s3_bucket.logs.id
}
