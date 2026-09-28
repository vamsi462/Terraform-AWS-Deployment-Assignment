# AWS Infrastructure Evolution: Monolithic to Containerized Microservices

**Author:** Vamsi Krishna Adusumalli

## Overview

This repository contains an end-to-end DevOps implementation demonstrating the architectural evolution of a multi-tier web application (Express.js Frontend, Flask Backend) on Amazon Web Services (AWS). Using Terraform for Infrastructure as Code (IaC), the deployment progresses through three distinct phases: a single-server monolith, a decoupled multi-server architecture, and a production-grade containerized deployment using AWS ECS Fargate and an Application Load Balancer (ALB).

## Technology Stack

* **Infrastructure as Code:** Terraform
* **Cloud Provider:** Amazon Web Services (AWS)
* **Compute & Orchestration:** EC2, ECS (Fargate), ECR
* **Networking & Security:** Custom VPC, Application Load Balancer (ALB), Internet Gateways, Security Groups
* **Containerization:** Docker
* **Application Stack:** Node.js (Express), Python (Flask)
* **State Management:** AWS S3 (Remote Backend)

---

## Architectural Phases

### Phase 1: Monolithic Deployment

A monolithic deployment provisioning a single AWS EC2 instance. Both the frontend (Express) and backend (Flask) applications are bootstrapped onto the same server via Terraform `user_data`, communicating internally over the loopback interface.

### Phase 2: Decoupled Architecture

A distributed setup separating the frontend and backend onto dedicated, isolated EC2 instances. This phase introduces cross-server communication over the public internet, utilizing dynamic environment variable injection (`BACKEND_URL`) to link the frontend to the backend's dynamic public IP.

### Phase 3: Containerized Microservices (Production-Grade)

A highly available, containerized architecture utilizing custom networking and serverless compute.

* **Custom VPC:** Provisioned with multiple public subnets across distinct Availability Zones.
* **AWS ECR:** Docker images built and pushed to private Elastic Container Registries.
* **AWS ECS (Fargate):** Applications deployed as serverless containers.
* **AWS ALB:** An Application Load Balancer acts as the single entry point, using path-based routing (`/api/*`) to direct traffic to the appropriate microservice.

---

## Execution Guide & Core Commands

### 1. Remote State Initialization

AWS S3 is utilized to store the Terraform state file remotely, ensuring state locking and consistency.

```bash
# Create S3 Bucket for Remote State
aws s3api create-bucket --bucket <bucket-name> --region ap-south-1 --create-bucket-configuration LocationConstraint=ap-south-1

# Initialize Terraform with S3 Backend
terraform init

```

### 2. Infrastructure Provisioning

Standard Terraform workflow used across all three deployment phases.

```bash
# Validate syntax and resource configurations
terraform validate

# Generate and review the execution plan
terraform plan

# Provision the infrastructure
terraform apply --auto-approve

# Safely tear down resources to prevent unnecessary billing
terraform destroy --auto-approve

```

### 3. Containerization & ECR Image Management

Building and publishing immutable Docker artifacts to AWS ECR.

```bash
# Authenticate local Docker daemon with AWS ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.ap-south-1.amazonaws.com

# Build, Tag, and Push Backend Image
docker build -t flask-backend-repo .
docker tag flask-backend-repo:latest <aws-account-id>.dkr.ecr.ap-south-1.amazonaws.com/flask-backend-repo:latest
docker push <aws-account-id>.dkr.ecr.ap-south-1.amazonaws.com/flask-backend-repo:latest

# Build, Tag, and Push Frontend Image
docker build -t express-frontend-repo .
docker tag express-frontend-repo:latest <aws-account-id>.dkr.ecr.ap-south-1.amazonaws.com/express-frontend-repo:latest
docker push <aws-account-id>.dkr.ecr.ap-south-1.amazonaws.com/express-frontend-repo:latest

```

---

## Key Technical Learnings

* **Infrastructure as Code (IaC) Mastery:** Transitioning from manual console deployments to declarative Terraform configurations ensures highly reproducible, version-controlled, and self-documenting infrastructure.
* **Remote State Management:** Utilizing AWS S3 as a remote backend decouples state files from the local environment, protecting critical state data and establishing the foundation for CI/CD pipeline integration and team collaboration.
* **Architectural Decoupling:** Separating components across independent EC2 instances highlighted the importance of security group ingress rules and dynamic IP management, mitigating single points of failure.
* **Container Orchestration & Serverless Compute:** Migrating from virtual machines to Docker containers orchestrated by AWS ECS Fargate abstracts underlying server maintenance, allowing deployments to focus strictly on application configuration and resource allocation (CPU/Memory).
* **Advanced Cloud Networking:** Designing a custom VPC from scratch reinforced core networking principles. Provisioning Internet Gateways, Route Tables, and multi-AZ Subnets is critical for meeting the strict high-availability requirements of AWS Application Load Balancers.
* **Traffic Routing:** Implementing path-based routing rules on an ALB demonstrates how a single public DNS endpoint can seamlessly manage and route traffic to multiple underlying private microservices.