# TaskFlow DevOps Capstone — Full Production Platform on AWS EKS

![AWS](https://img.shields.io/badge/AWS-EKS-orange?style=for-the-badge&logo=amazonaws)
![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?style=for-the-badge&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-326CE5?style=for-the-badge&logo=kubernetes)
![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?style=for-the-badge&logo=argo)
![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions)
![Helm](https://img.shields.io/badge/Helm-Deployed-0F1689?style=for-the-badge&logo=helm)
![Prometheus](https://img.shields.io/badge/Monitoring-Prometheus-E6522C?style=for-the-badge&logo=prometheus)
![Grafana](https://img.shields.io/badge/Monitoring-Grafana-F46800?style=for-the-badge&logo=grafana)

---

## What is TaskFlow?

TaskFlow is a full-stack task management application built as a **3-phase DevOps capstone project**. The application itself is simple — the focus is entirely on the **infrastructure, automation, security, and operations** surrounding it.

This project demonstrates what a real-world production DevOps setup looks like on AWS — from raw infrastructure provisioning all the way to GitOps, autoscaling, TLS, and observability.

**🌐 Live at: https://app.okorojeremiah.online**

---

## The 3-Phase Journey

| Phase | Focus | Status |
|---|---|---|
| [Project 1](./project-1-infra/README.md) | Infrastructure Provisioning with Terraform | ✅ Complete |
| [Project 2](./project-2-app/README.md) | CI/CD, Helm, ALB Ingress, Monitoring | ✅ Complete |
| [Project 3](./project-3-ops/README.md) | GitOps, Auth, Autoscaling, TLS, RDS | ✅ Complete |

---

## Full Tech Stack

| Category | Technology |
|---|---|
| Cloud | AWS (EKS, ECR, RDS, ACM, Route 53, Cognito, IAM) |
| Infrastructure as Code | Terraform |
| Container Orchestration | Kubernetes (EKS) |
| Package Management | Helm |
| CI/CD | GitHub Actions |
| Pipeline Security | OIDC (no stored credentials) |
| GitOps | ArgoCD |
| Authentication | AWS Cognito |
| Autoscaling | HPA + Metrics Server |
| DNS | ExternalDNS + Route 53 |
| TLS | AWS Certificate Manager |
| Database | RDS PostgreSQL |
| Monitoring | Prometheus + Grafana |
| Security Scanning | Trivy |
| Networking | VPC, ALB, Ingress Controller |
| Secret Management | Kubernetes Secrets + IRSA |

---

## Repository Structure

```text
taskflow-eks-platform/
├── README.md                        # This file
├── project-1-infra/                 # Phase 1 — Terraform infrastructure
│   ├── README.md
│   └── terraform/
├── project-2-app/                   # Phase 2 — Application delivery
│   ├── README.md
│   ├── .github/workflows/           # GitHub Actions CI/CD
│   ├── backend/                     # Backend source code
│   ├── frontend/                    # Frontend source code
│   └── helm/taskflow/               # Helm chart
└── project-3-ops/                   # Phase 3 — Operations
    ├── README.md
    ├── argocd/                      # ArgoCD Application manifests
    ├── externaldns/                 # ExternalDNS configuration
    ├── iam/                         # IAM roles (Terraform)
    └── monitoring/                  # Prometheus + Grafana values
```

---

## Architecture Overview

### Phase 1 — Infrastructure
Terraform provisions a custom VPC, public/private subnets, EKS cluster with Spot Instance node groups, ECR repositories, S3 remote state, and DynamoDB state locking.

### Phase 2 — Application Delivery
GitHub Actions builds Docker images, runs Trivy security scans, and pushes to ECR. Helm deploys frontend and backend to EKS via an ALB Ingress Controller with OIDC/IRSA authentication.

### Phase 3 — Production Operations
ArgoCD watches Git and syncs the cluster automatically. Cognito handles user authentication. OIDC secures the CI/CD pipeline. HPA autoscales pods. ExternalDNS manages Route 53 records. ACM provides wildcard HTTPS. RDS persists data. Prometheus and Grafana provide full observability.

---

## Key Achievements Across All Phases

-  Full AWS infrastructure provisioned as code with Terraform
-  Containerized application with automated CI/CD pipeline
-  Zero stored AWS credentials — OIDC throughout
-  Live app on custom domain with HTTPS
-  Full GitOps loop — Git push → automatic cluster sync
-  Persistent database storage with RDS PostgreSQL
-  Autoscaling with HPA based on real CPU/memory metrics
-  Full cluster observability with Prometheus and Grafana
-  Container security scanning with Trivy

---

## Author

**Onyedika Okoro**

Cloud / DevOps Engineer

Learning in public • Building real projects • Growing daily

[GitHub](https://github.com/OnyiGlobal2025) | [LinkedIn](https://linkedin.com/in/onyedika-okoro/)