output "part2_flask_url" {
  description = "URL to access the dedicated Flask backend"
  value       = "http://${aws_instance.flask_instance.public_ip}:5000"
}

output "part2_express_url" {
  description = "URL to access the dedicated Express frontend"
  value       = "http://${aws_instance.express_instance.public_ip}:3000"
}