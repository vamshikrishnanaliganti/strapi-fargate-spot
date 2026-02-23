output "ecr_repo_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.strapi.repository_url
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS"
  value       = aws_lb.main.dns_name
}

output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "ecs_cluster" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service" {
  description = "ECS Service Name"
  value       = aws_ecs_service.strapi.name
}

output "cloudwatch_log_group" {
  description = "CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.strapi.name
}
