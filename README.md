![ChatGPT Image May 12, 2025, 03_34_49 PM](https://github.com/user-attachments/assets/42ffaed4-84d0-4a4b-9fcc-25687a72d780)# ☁️ Cloud Cost Dashboard

![Infrastructure: Terraform](https://img.shields.io/badge/infrastructure-terraform-623CE4?logo=terraform)
![App: FastAPI](https://img.shields.io/badge/backend-fastapi-009688?logo=fastapi)
![CI/CD: GitHub Actions](https://img.shields.io/badge/ci/cd-github%20actions-blue?logo=githubactions)

A fully containerized FastAPI application deployed to AWS using ECS Fargate, RDS, ALB, and Terraform. This project showcases **end-to-end DevOps engineering**, including infrastructure automation, secrets management, and CI/CD.

---

## 🚀 Features

- **⚙️ FastAPI Backend** — Serves cost data and optimization recommendations over RESTful endpoints.
- **📦 Docker + ECS Fargate** — Containerized deployment with zero EC2 management.
- **🔐 Secrets Managed with SSM** — DB credentials stored in AWS Systems Manager Parameter Store.
- **🌐 Load Balanced** — Publicly accessible via Application Load Balancer.
- **📊 PostgreSQL (RDS)** — Stores cost metrics in a secure, private DB.
- **⚙️ GitHub Actions CI/CD** — Build, push, and deploy pipeline from `main` branch.

---

## 🧱 Architecture

![Cloud Cost Dashboard Architecture]

![image](https://github.com/user-attachments/assets/9e137745-cd7b-4533-87d1-5d6a9f2f0794)


> ECS Fargate + RDS + ALB + Terraform modules

---

## 📡 API Endpoints

| Method | Route                | Description                              |
|--------|----------------------|------------------------------------------|
| GET    | `/`                  | Welcome message                          |
| GET    | `/health`            | Health check used by ALB                 |
| GET    | `/costs`             | Get cloud cost entries from RDS          |
| GET    | `/recommendations`   | Suggest EC2 rightsizing based on dummy CPU usage |

Example response:
```json
[
  {
    "instance": "t3.medium",
    "region": "us-east-1",
    "cpu_avg": 18.0,
    "recommendation": "Consider downgrading to t3.small"
  }
]
```
🧪 Stack
Layer	Tech / Tool
App	Python, FastAPI, SQLModel
Database	PostgreSQL on Amazon RDS
Infra	Terraform (modular), AWS (VPC, ECS, ALB, RDS)
CI/CD	GitHub Actions
Secrets	AWS SSM Parameter Store

⚙️ How to Deploy
Prerequisites:

AWS account & CLI configured

Terraform ≥ v1.0 installed

ECR repo created & DB credentials stored in SSM:

/cloud-cost-dashboard/db_username

/cloud-cost-dashboard/db_password

1. 📁 Clone and Configure
git clone https://github.com/Bilal31313/cloud-cost-dashboard.git
cd cloud-cost-dashboard/terraform
2. 🌍 Terraform Apply
terraform init
terraform apply
This provisions:

VPC, public/private subnets, NAT gateway

ECS Fargate cluster

ALB + target group

RDS PostgreSQL (private subnet)

IAM roles for ECS and SSM access

3. 🐳 Build and Push Docker Image (manual or CI)
# Login to ECR
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 891377023859.dkr.ecr.eu-west-2.amazonaws.com

# Build and push image
docker build -t cloud-cost-dashboard:v21 .
docker tag cloud-cost-dashboard:v21 891377023859.dkr.ecr.eu-west-2.amazonaws.com/cloud-cost-dashboard:v21
docker push 891377023859.dkr.ecr.eu-west-2.amazonaws.com/cloud-cost-dashboard:v21

✅ Alternatively: Just push to main and let GitHub Actions handle this.

🔒 Security Highlights
No hardcoded secrets — credentials pulled securely at runtime from Parameter Store

RDS runs in private subnets — not publicly accessible

IAM roles follow least privilege

ALB is the only public entrypoint

🧱 Project Structure
cloud-cost-dashboard/
├── app/               # FastAPI app
│   ├── main.py        # Entry point
│   ├── routers/       # /costs and /recommendations
│   ├── models/        # SQLModel models
│   └── db/            # DB session
├── terraform/         # IaC root
│   ├── main.tf        # Assembles modules
│   ├── variables.tf   # Config
│   └── modules/       # Reusable Terraform code
│       ├── ecs/
│       ├── rds/
│       ├── network/
│       └── iam/
├── Dockerfile         # App container
└── .github/workflows/ci.yml # CI/CD pipeline

🛠️ Future Enhancements
✅ CI/CD via GitHub Actions

📊 Real-time cost integration (Cost Explorer API or CloudWatch)

📈 Frontend (React or Grafana dashboard)

🔔 Cost threshold alerting via SNS

👨‍💻 Author
Bilal Khawaja
Cloud Engineer | AWS Certified Solutions Architect – Associate
LinkedIn http://www.linkedin.com/in/bilal-khawaja-65b883243
GitHub: @Bilal31313

💬 Feedback
Found a bug or want to contribute?
Open an issue or PR – this is a learning-focused DevOps showcase.

