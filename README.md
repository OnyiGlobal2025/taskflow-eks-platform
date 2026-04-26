# 🚀 Project 1: Production-Style AWS EKS Platform with Terraform

![AWS](https://img.shields.io/badge/AWS-EKS-orange?style=for-the-badge&logo=amazonaws)
![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?style=for-the-badge&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-326CE5?style=for-the-badge&logo=kubernetes)
![Remote State](https://img.shields.io/badge/Remote%20State-S3-success?style=for-the-badge)
![Locking](https://img.shields.io/badge/State%20Lock-DynamoDB-blue?style=for-the-badge)

---

# 📌 Overview

This project is **Phase 1** of my larger **TaskFlow Microservices DevOps Capstone**, where I am building a full production-ready cloud platform in 3 stages:

- ✅ **Project 1:** Infrastructure Provisioning with Terraform  
- ⏭️ **Project 2:** Docker + CI/CD + Monitoring  
- ⏭️ **Project 3:** GitOps + ArgoCD + Advanced Kubernetes Operations  

In this phase, I built a **secure, scalable and cost-aware AWS Kubernetes foundation** using Terraform.

---

# 🏗️ Architecture Diagram

![Architecture Diagram](images/project1-architecture.png)

---

# ⚙️ Tech Stack

| Category | Tools |
|--------|------|
| Cloud Provider | AWS |
| Infrastructure as Code | Terraform |
| Container Orchestration | Amazon EKS |
| Networking | VPC, Subnets, Route Tables, NAT Gateway |
| Registry | Amazon ECR |
| State Management | Amazon S3 |
| State Locking | DynamoDB |
| Cost Optimization | Spot Instances |
| Security | IAM Roles |

---

# 🧱 What Was Built

---

## 🌐 1. Custom AWS Networking

Provisioned a dedicated VPC:

```text
10.0.0.0/16