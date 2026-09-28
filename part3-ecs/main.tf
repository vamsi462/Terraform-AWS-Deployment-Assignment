terraform {
  backend "s3" {
    key    = "state/terraform.tfstate"
    region = "ap-south-1"
    bucket ="vamsi-terraform-state-462"
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------
# Step 12: ECR Repositories
# ---------------------------------------------------------
resource "aws_ecr_repository" "flask_backend" {
  name         = "flask-backend-repo"
  force_delete = true 
}

resource "aws_ecr_repository" "express_frontend" {
  name         = "express-frontend-repo"
  force_delete = true
}