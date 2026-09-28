output "ecr_flask_repository_url" {
  value = aws_ecr_repository.flask_backend.repository_url
}

output "ecr_express_repository_url" {
  value = aws_ecr_repository.express_frontend.repository_url
}

output "alb_dns_name" {
  description = "Public URL for accessing the application via ALB"
  value       = "http://${aws_lb.main_alb.dns_name}"
}