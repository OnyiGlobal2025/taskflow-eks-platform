markdown# Project 3: GitOps, Security & Advanced Kubernetes Operations

![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?style=for-the-badge&logo=argo)
![AWS Cognito](https://img.shields.io/badge/Auth-Cognito-FF9900?style=for-the-badge&logo=amazonaws)
![OIDC](https://img.shields.io/badge/CI%2FCD-OIDC-6DB33F?style=for-the-badge&logo=githubactions)
![HPA](https://img.shields.io/badge/Scaling-HPA-326CE5?style=for-the-badge&logo=kubernetes)
![ExternalDNS](https://img.shields.io/badge/DNS-ExternalDNS-0052CC?style=for-the-badge)
![ACM](https://img.shields.io/badge/TLS-ACM-FF9900?style=for-the-badge&logo=amazonaws)
![RDS](https://img.shields.io/badge/Database-RDS%20PostgreSQL-336791?style=for-the-badge&logo=postgresql)
![Prometheus](https://img.shields.io/badge/Monitoring-Prometheus-E6522C?style=for-the-badge&logo=prometheus)
![Grafana](https://img.shields.io/badge/Monitoring-Grafana-F46800?style=for-the-badge&logo=grafana)

---

## Overview

This is **Phase 3** of the **TaskFlow Microservices DevOps Capstone** — the most advanced phase of the project. Building on the infrastructure provisioned in Project 1 and the CI/CD pipeline from Project 2, this phase focuses on production-grade operations:

- ✅ **Project 1:** Infrastructure Provisioning with Terraform
- ✅ **Project 2:** Docker + CI/CD + Helm + ALB + Monitoring
- ✅ **Project 3:** GitOps + Auth + Autoscaling + DNS + TLS + RDS + Observability

The goal was to transform the Taskflow app from a manually deployed application into a **fully automated, self-healing, securely accessible production system**.

---

## Live Application

**🌐 https://app.okorojeremiah.online**

- Secured with HTTPS via AWS ACM wildcard certificate
- DNS managed automatically by ExternalDNS + Route 53
- Data persisted in RDS PostgreSQL

---

## Architecture Diagram

![Architecture Diagram](docs/screenshots/project3-architecture.png)

---

## Tech Stack

| Category | Tools |
|---|---|
| GitOps / CD | ArgoCD |
| Authentication | AWS Cognito |
| Pipeline Auth | OIDC (GitHub Actions → AWS) |
| Autoscaling | Kubernetes HPA + Metrics Server |
| DNS Management | ExternalDNS + Route 53 |
| TLS / HTTPS | AWS Certificate Manager (ACM) |
| Database | RDS PostgreSQL (db.t3.micro) |
| Monitoring | Prometheus + Grafana |
| Secret Management | Kubernetes Secrets |
| Package Management | Helm |
| Domain Registrar | Namecheap → delegated to Route 53 |

---

## What Was Built

---

### 1. ArgoCD for GitOps CD

Installed ArgoCD via Helm into a dedicated `argocd` namespace. Connected it to the GitHub repository and created an `Application` manifest that watches the `project-2-app/helm/taskflow` path.

**Why this matters:**
Before ArgoCD, deployments required manual `helm upgrade` commands. Now, every `git push` to main automatically syncs the cluster — no manual intervention. If someone manually changes cluster state, ArgoCD detects the drift and self-heals.

**Key configuration:**
- `syncPolicy.automated.selfHeal: true` — auto-reverts manual changes
- `syncPolicy.automated.prune: true` — removes deleted resources automatically

## ArgoCD Resource Tree
![ArgoCD Resource Tree](docs/screenshots/argocd-resource-tree.png)

## ArgoCD Applications
![ArgoCD Applications](docs/screenshots/argocd-applications.png)

---

### 2. AWS Cognito Authentication

Provisioned an AWS Cognito User Pool with a hosted UI for user authentication. Created an app client with OAuth 2.0 authorization code grant flow.

**Why this matters:**
Building authentication from scratch is complex and insecure. Cognito handles user registration, login, email verification, password resets, and JWT token generation — all managed by AWS. The backend verifies JWT tokens using Cognito's public JWKS endpoint.

**What was configured:**
- User Pool with email sign-in
- Self-registration enabled
- Hosted UI with callback URL
- Cognito credentials stored as Kubernetes secrets (never hardcoded)
- Backend middleware to verify JWT tokens via `jwks-rsa`

## Cognito User Pool
![Cognito User Pool](docs/screenshots/cognito-user-pool.png)

## Cognito Hosted UI
![Cognito Hosted UI](docs/screenshots/cognito-hosted-ui.png)

---

### 3. OIDC Authentication for CI/CD Pipeline

Replaced long-lived AWS access keys in GitHub Actions with OIDC (OpenID Connect) authentication. The pipeline now assumes an IAM role using a short-lived token issued by GitHub per workflow run.

**Why this matters:**
Stored AWS credentials in GitHub secrets are a security risk — if leaked, they provide permanent access. OIDC tokens are temporary, scoped to a specific repo and branch, and expire automatically after each job. This is the industry standard for secure CI/CD authentication.

**What was configured:**
- OIDC Identity Provider added to AWS IAM
- IAM role `taskflow-github-actions-role` scoped to `OnyiGlobal2025/taskflow-eks-platform` main branch
- GitHub Actions workflow updated with `id-token: write` permission
- Old `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` secrets deleted

## OIDC Pipeline Success
![OIDC Pipeline](docs/screenshots/oidc-pipeline-success.png)

---

### 4. Horizontal Pod Autoscaler (HPA)

Installed Metrics Server and configured HPA for both frontend and backend deployments.

**Why this matters:**
A fixed number of pods cannot handle variable traffic. HPA monitors real CPU and memory usage and automatically scales pods up when load increases and scales back down when traffic drops — saving cost during quiet periods.

**Configuration:**

| Deployment | Min Pods | Max Pods | CPU Threshold | Memory Threshold |
|---|---|---|---|---|
| taskflow-backend | 1 | 5 | 70% | 80% |
| taskflow-frontend | 2 | 6 | 70% | 80% |

## HPA Metrics
![HPA](docs/screenshots/hpa-metrics.png)

---

### 5. ExternalDNS for Dynamic DNS Management

Installed ExternalDNS via Helm with an IRSA-scoped IAM role. Configured it to watch ingress resources and automatically create Route 53 DNS records.

**Why this matters:**
Without ExternalDNS, every time the ALB DNS name changes you'd manually update DNS records. ExternalDNS reads the `external-dns.alpha.kubernetes.io/hostname` annotation from your ingress and creates/updates Route 53 records automatically — zero manual DNS management.

**Real proof:**
After deploying the updated ingress with `app.okorojeremiah.online`, ExternalDNS logs showed:
Desired change: CREATE app.okorojeremiah.online A
4 record(s) were successfully updated

## ExternalDNS Logs
![ExternalDNS](docs/screenshots/externaldns-logs.png)

---

### 6. ACM for TLS Certification

Requested a wildcard ACM certificate covering `okorojeremiah.online` and `*.okorojeremiah.online`. Validated via Route 53 DNS validation and attached to the ALB ingress.

**Why this matters:**
HTTPS encrypts all traffic between users and the ALB. A wildcard certificate covers all subdomains — `app.`, `api.`, `argocd.` — with a single certificate that auto-renews for free.

**Key ingress annotations added:**
```yaml
alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:..."
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80,"HTTPS":443}]'
alb.ingress.kubernetes.io/ssl-redirect: "443"
```

## ACM Certificate Issued
![ACM Certificate](docs/screenshots/acm-certificate.png)

## App Running on HTTPS
![HTTPS App](docs/screenshots/app-https.png)

---

### 7. RDS for Persistent Database Storage

Provisioned an RDS PostgreSQL instance in private subnets with a dedicated security group allowing only VPC traffic on port 5432.

**Why this matters:**
Pod storage is ephemeral — data is lost when pods restart. RDS provides managed, persistent storage with automatic backups, encryption at rest, and high availability. This is standard for any production application.

**Configuration:**
- Engine: PostgreSQL 15.7
- Instance: db.t3.micro
- Storage: 20GB encrypted (gp2)
- Subnet group: private subnets only
- Security group: port 5432 open to VPC CIDR only
- Credentials injected via Kubernetes secrets (never hardcoded)
- Backup retention: 7 days

**Real proof:**
Tasks added to the app persisted after closing and reopening the browser — confirming the backend is reading and writing to RDS correctly.

## RDS Instance
![RDS](docs/screenshots/rds-instance.png)

---

### 8. GitOps Integration with ArgoCD

Created ArgoCD `Application` manifests for the taskflow Helm chart. Tested the full GitOps loop by pushing a change to Git and watching ArgoCD automatically sync the cluster within 3 minutes.

**Why this matters:**
This closes the full DevOps loop — code change → Git push → ArgoCD detects → cluster updated automatically. No manual deployment steps. Full audit trail in Git.

**GitOps loop proven:**
1. Updated ingress `host` rule in Git
2. Pushed to main
3. ArgoCD detected the change
4. Cluster synced automatically — no `helm upgrade` needed

---

### 9. Monitoring and Observability

Installed `kube-prometheus-stack` via Helm providing Prometheus and Grafana with pre-built Kubernetes dashboards.

**Why this matters:**
Without monitoring you're flying blind. Prometheus scrapes metrics from every pod, node, and the Kubernetes API. Grafana visualizes them in real time — you can see exactly which pods are consuming CPU, which nodes are under pressure, and set alerts before things break.

**Dashboards configured:**
- Kubernetes / Compute Resources / Cluster — overall cluster health
- Kubernetes / Compute Resources / Namespace (Pods) — per-pod metrics
- Kubernetes / Nodes — node-level CPU and memory

**Credentials secured:**
Grafana admin password stored in a Kubernetes secret — never hardcoded in values.yaml.

## Grafana Cluster Dashboard
![Grafana](docs/screenshots/grafana-cluster.png)

## Grafana Pod Dashboard
![Grafana Pods](docs/screenshots/grafana-pods.png)

---

## Project Structure

```text
taskflow-eks-platform/
├── project-1-infra/           # Terraform EKS infrastructure
├── project-2-app/             # Application Helm charts and CI/CD
│   ├── .github/workflows/     # GitHub Actions pipeline
│   ├── helm/taskflow/         # Helm chart (frontend, backend, ingress)
│   └── k8s/                   # Raw Kubernetes manifests
│       ├── argocd/            # ArgoCD Application manifests
│       ├── backend/           # Backend deployment + service
│       ├── cognito/           # Cognito secret manifest
│       ├── frontend/          # Frontend deployment + service
│       ├── hpa/               # HPA manifests
│       └── rds/               # RDS secret manifest
└── project-3-ops/             # Project 3 operations configs
    ├── argocd/                # ArgoCD application manifests
    ├── externaldns/           # ExternalDNS Helm values + IAM policy
    ├── iam/                   # GitHub Actions OIDC IAM role (Terraform)
    └── monitoring/            # Prometheus + Grafana Helm values
```

---

## Security Practices Applied

| Practice | Implementation |
|---|---|
| No stored AWS credentials | OIDC replaces access keys in CI/CD |
| Secrets never hardcoded | All credentials in Kubernetes secrets |
| Database not publicly accessible | RDS in private subnets, VPC-only access |
| HTTPS enforced | HTTP → HTTPS redirect via ALB annotation |
| Wildcard TLS certificate | ACM covers all subdomains |
| IAM least privilege | IRSA roles scoped per service |
| Container scanning | Trivy in CI pipeline (from Project 2) |

---

## Challenges & Lessons Learned

| Challenge | Root Cause | Resolution |
|---|---|---|
| ArgoCD conflicting with `helm upgrade` | ArgoCD owns resources — Helm can't modify them directly | Pushed changes to Git and let ArgoCD sync automatically |
| ExternalDNS sync status Unknown in ArgoCD | Git path only had values.yaml, not a full Helm chart | Removed ExternalDNS from ArgoCD management — it runs independently via Helm |
| HPA showing `<unknown>` metrics | Pods had no resource requests defined | Added CPU/memory requests to deployment manifests via `kubectl patch` |
| ACM certificate showing "Not secure" | Original certificate didn't include wildcard `*.okorojeremiah.online` | Requested new certificate with both root and wildcard domains |
| Load test pod failing on Windows | Git Bash on Windows can't exec Linux containers | Used manual `kubectl scale` to demonstrate scaling behavior |
| RDS password rejected | `@` symbol not allowed in RDS passwords | Used alphanumeric password without special characters |
| Helm upgrade conflict with ArgoCD | ArgoCD controller owns the resources | Understood that GitOps means Git is the only update mechanism |

---

## Skills Demonstrated

- GitOps with ArgoCD
- AWS Cognito user authentication
- OIDC-based CI/CD security
- Kubernetes autoscaling (HPA)
- Dynamic DNS management
- TLS/HTTPS certificate management
- Managed database provisioning (RDS)
- Kubernetes secret management
- Helm chart management
- Prometheus and Grafana observability
- IRSA (IAM Roles for Service Accounts)
- Production security practices

---

## Key Achievements

- 🌐 Live app accessible at `https://app.okorojeremiah.online`
- 🔒 Fully secured with HTTPS and ACM wildcard certificate
- 🗄️ Data persists across pod restarts via RDS PostgreSQL
- 🔄 Full GitOps loop — Git push triggers automatic cluster sync
- 📊 Real-time cluster observability via Grafana dashboards
- 🔐 Zero stored AWS credentials — OIDC throughout
- ⚖️ Auto-scaling configured and proven working

---

## Author

Onyedika Okoro

Cloud / DevOps Engineer

Learning in public • Building real projects • Growing daily
