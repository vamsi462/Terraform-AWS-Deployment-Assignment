# 🚀 AWS Infrastructure Evolution: Monolithic to Containerized Microservices

**Author:** Vamsi Krishna Adusumalli

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

## 📖 Overview
This repository contains an end-to-end DevOps implementation demonstrating the architectural evolution of a multi-tier web application (Express.js Frontend, Flask Backend) on Amazon Web Services (AWS). 

Using Terraform for Infrastructure as Code (IaC), the deployment progresses through three distinct phases: a single-server monolith, a decoupled multi-server architecture, and a production-grade containerized deployment using AWS ECS Fargate and an Application Load Balancer (ALB).

---

## 🏗️ Final Architecture (Phase 3)

*GitHub automatically renders this flowchart to visualize the final containerized networking routing.*

```mermaid
graph TD
    Client([🌐 Client Browser]) -->|HTTP Port 80| IGW[AWS Internet Gateway]
    IGW --> ALB[Application Load Balancer]
    
    subgraph Custom AWS VPC [Custom AWS VPC 10.0.0.0/16]
        ALB -->|Path: /*| Frontend[Express.js Container \n ECS Fargate - Port 3000]
        ALB -->|Path: /api/*| Backend[Flask Container \n ECS Fargate - Port 5000]
        Frontend -.->|Internal API Call| Backend
    end
    
    subgraph State Management
        TF[Terraform] -->|State Lock & Store| S3[(AWS S3 Backend)]
    end