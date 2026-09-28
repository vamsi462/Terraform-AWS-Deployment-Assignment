terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "vamsi-terraform-state-462"
    key    = "state/terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = "ap-south-1"
}
# Fetch the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Security Group to allow SSH, Flask (5000), and Express (3000)
resource "aws_security_group" "part1_sg" {
  name        = "part1-flask-express-sg"
  description = "Allow inbound traffic for Flask and Express"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Dedicated EC2 Instance for Flask Backend
resource "aws_instance" "flask_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.part1_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y git python3 python3-pip

              cd /home/ubuntu
              git clone https://github.com/vamsi462/docker-assignment-node-express-flask.git myapp
              
              cd /home/ubuntu/myapp/backend
              pip3 install flask
              nohup python3 app.py > /home/ubuntu/flask.log 2>&1 &
              EOF

  tags = {
    Name = "Part2-Flask-Backend"
  }
}

# Dedicated EC2 Instance for Express Frontend
resource "aws_instance" "express_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.part1_sg.id]

  # Notice how we inject the flask_instance.public_ip into the BACKEND_URL variable below!
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y git

              curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
              apt-get install -y nodejs

              cd /home/ubuntu
              git clone https://github.com/vamsi462/docker-assignment-node-express-flask.git myapp

              cd /home/ubuntu/myapp/frontend
              npm install
              npm install axios express
              
              export BACKEND_URL="http://${aws_instance.flask_instance.public_ip}:5000/api/data"
              nohup node server.js > /home/ubuntu/express.log 2>&1 &
              EOF

  tags = {
    Name = "Part2-Express-Frontend"
  }
}