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

# EC2 Instance Deploying Flask Express GitHub Code
resource "aws_instance" "single_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.part1_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # 1. Install System Dependencies & Git
              apt-get update -y
              apt-get install -y git python3 python3-pip

              # 2. Install Node 18 (Fixing previous SyntaxError)
              curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
              apt-get install -y nodejs

              # 3. Clone Your Repository
              cd /home/ubuntu
              git clone https://github.com/vamsi462/docker-assignment-node-express-flask.git myapp
              chown -R ubuntu:ubuntu myapp

              # 4. Start Flask Backend (Port 5000)
              cd /home/ubuntu/myapp/backend
              pip3 install flask
              nohup python3 app.py > /home/ubuntu/flask.log 2>&1 &

              # 5. Start Express Frontend (Port 3000)
              cd /home/ubuntu/myapp/frontend
              npm install
              npm install axios express  # Backup ensure packages are installed
              nohup node server.js > /home/ubuntu/express.log 2>&1 &
              EOF

  tags = {
    Name = "Assignment-Part1"
  }
}