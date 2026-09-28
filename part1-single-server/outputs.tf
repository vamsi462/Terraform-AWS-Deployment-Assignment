output "part1_instance_public_ip" {
  description = "Public IP of the Single EC2 Instance"
  value       = aws_instance.single_instance.public_ip
}

output "part1_flask_url" {
  description = "URL to access the Flask backend"
  value       = "http://${aws_instance.single_instance.public_ip}:5000"
}

output "part1_express_url" {
  description = "URL to access the Express frontend"
  value       = "http://${aws_instance.single_instance.public_ip}:3000"
}