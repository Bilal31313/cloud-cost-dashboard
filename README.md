Cloud Cost Dashboard
A containerized FastAPI application and AWS infrastructure (provisioned with Terraform) to track and optimize AWS cloud costs. This project demonstrates end-to-end DevOps skills by deploying a cost visibility dashboard on AWS ECS Fargate with continuous integration and deployment.
Project Overview
Cloud Cost Dashboard provides a RESTful API backend that aggregates cloud cost data and offers basic cost optimization recommendations. Key features include:
FastAPI Backend: A Python FastAPI app with endpoints for retrieving cloud cost information and recommendations (e.g. rightsizing EC2 instances).
AWS Infrastructure as Code: Terraform modules set up a scalable AWS environment – including VPC networking, an ECS Fargate cluster for the API, an Application Load Balancer, and an Amazon RDS PostgreSQL database for storing cost data.
Containerization: The app is containerized with Docker. The container is deployed on AWS ECS Fargate, ensuring a serverless operation with minimal maintenance overhead.
Continuous Deployment: GitHub Actions workflows automate linting, testing, Docker image build/push to ECR, and Terraform deployment to AWS on each merge to the main branch.
Secure Configuration: Sensitive credentials (DB username/password) are stored in AWS Systems Manager Parameter Store and injected into the container at runtime. AWS IAM roles and policies are configured to restrict access (e.g., ECS tasks can read only the required parameters).
Architecture
The diagram below illustrates the high-level architecture:
FastAPI Application: Serves HTTP requests via defined endpoints (e.g., /costs, /recommendations, /health). On startup, it connects to an RDS PostgreSQL database (initialized with a “costs” table) and registers routes for cost data retrieval and optimization suggestions.
Docker Container: The FastAPI app runs in a Docker container (based on a slim Python 3.11 image) using Uvicorn. The container exposes port 8000 for the application.
AWS ECS Fargate: The container is deployed as a service in ECS Fargate. Task definition configures the container port and environment variables for database connection (hostname, etc.) and secrets (fetched from SSM Parameter Store).
Application Load Balancer (ALB): An ALB fronts the ECS service, listening on port 80 HTTP. It routes traffic to the ECS tasks (target port 8000). Health checks are configured on the root (/) endpoint to ensure the service is running.
Amazon RDS: A PostgreSQL database stores cloud cost records (e.g., costs per service). The FastAPI app uses SQLModel (SQLAlchemy + Pydantic) to interact with this database. The RDS instance resides in private subnets for security.
Networking & Security: Terraform provisions a new VPC with public and private subnets. The ECS service runs in private subnets with outbound internet access through a NAT Gateway (for external API calls if needed). Security groups restrict access: the ALB can reach the ECS tasks on the container port, and ECS tasks can reach the RDS database on its port. No public exposure of the database.
Setup and Deployment
Prerequisites:
AWS account with appropriate permissions (IAM user or role with rights to create ECS, ALB, RDS, etc.).
Terraform installed locally (>= v1.0) and AWS CLI configured, or use the provided GitHub Actions pipeline with AWS credentials configured as repository secrets.
Docker installed (if building the image locally) and AWS ECR for container registry.
Deployment Steps:
Infrastructure Configuration: Adjust any default variables in terraform/variables.tf if needed (e.g., AWS region, instance sizes). Ensure you have created two SSM Parameter Store entries for the database credentials:
/cloud-cost-dashboard/db_username – the DB master username (e.g., “postgres”).
/cloud-cost-dashboard/db_password – the DB password (match the one used in Terraform, or override via Terraform variables).

Initialize Terraform:
cd terraform/
terraform init
This will download required providers and modules.

Terraform Apply:
terraform apply

Terraform will create all resources: VPC, subnets, ECS cluster, ALB, target group, IAM roles, RDS instance, etc. Note: The first apply may take a few minutes, especially for RDS provisioning.
Build & Push Docker Image:
Update the image repository URL in Terraform or ECS task definition if needed. By default, an ECR repository is expected.
Build the Docker image locally:
docker build -t <your ECR repo>:latest .

Authenticate to ECR and push the image:
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com  
docker push <your ECR repo>:latest

(Alternatively, skip these steps if using GitHub Actions – the pipeline will build and push the image automatically.)
Continuous Deployment (CI/CD):
On pushing to the main branch, GitHub Actions will run the workflow defined in .github/workflows/ci.yml. This pipeline will:
Lint and format the code (using Black, Flake8, iSort) and validate Terraform.
Build the Docker image and push to ECR.
Apply Terraform changes to update the ECS service with the new image (deploying the latest version of the app).
Monitor the Actions tab for any deployment issues. On success, the FastAPI app will be updated on ECS.
Endpoints and Usage:
Base URL: The ALB DNS (output by Terraform) will serve the API. For example: http://<alb-url>/
GET / – Welcome message to verify the API is up.
GET /health – Health check endpoint, returns {"status":"ok"} if the service is running. Used by the ALB for health monitoring.
GET /costs – Retrieve stored cloud cost data. Returns JSON of cost entries (e.g., service name, cost amount, region, etc.).
GET /recommendations – Provides cost optimization recommendations. For each service (currently focusing on EC2), if the average CPU utilization is low and the instance is oversized, the API suggests a cheaper instance type. Example response:
[
  {
    "instance": "t3.medium",
    "region": "us-east-1",
    "cpu_avg": 18.0,
    "recommendation": "Consider downgrading to t3.small to reduce costs"
  }
]

(Note: In this demo, recommendations are generated from dummy CPU metrics. In a real scenario, integration with AWS CloudWatch or Compute Optimizer would provide actual utilization data.)
Project Structure
app/ – FastAPI application package.
main.py – Application entry point (creates FastAPI app, includes routers, sets up DB on startup).
routers/ – Module containing API route definitions.
costs.py – Routes for cost data (e.g., list costs). Retrieves data from the database.
recommendations.py – Routes for optimization suggestions. Computes recommendations based on cost data and simulated utilization metrics.
models.py – SQLModel definitions for data models (e.g., CostEntry with fields for service, cost, region, etc.).
db/session.py – Database session management. Defines the SQLModel engine and connection string (built from environment variables for DB host, user, pass).
terraform/ – Infrastructure-as-code definitions.
main.tf – Pulls together module calls for network, ECS, RDS, etc., and passes necessary variables. Also outputs useful info (like ALB URL).
modules/ – Reusable Terraform modules for:
network (VPC, subnets, routing, NAT gateway)
ecs (ECS cluster, task definition, service, ALB listener and target group)
rds (PostgreSQL instance, subnet group, parameter group, and security group)
iam (IAM roles and policies for ECS task execution, allowing pulling from ECR and reading SSM parameters)
Dockerfile – Configuration to containerize the FastAPI app. Uses a Python 3.11 slim base, installs dependencies, and launches Uvicorn server on container port 8000.
.github/workflows/ci.yml – GitHub Actions workflow for CI/CD, as described above.
Security and Best Practices
This project follows best practices suitable for a production-grade environment:
Least Privilege IAM: The ECS task’s execution role is limited to pulling the container image from ECR and reading specific parameters from SSM (DB credentials). No broad wildcard policies.
Secrets Management: No plaintext secrets in the repository. Database credentials are pulled from secure storage (SSM Parameter Store) at runtime. The Terraform state does not contain plaintext passwords (the RDS password is provided via variable and stored in AWS secrets).
Network Security: Database is not publicly accessible; it’s in private subnets with security group rules to only allow the app to connect. The ALB is the only public entry point.
Reliability: Health checks on ECS tasks ensure that only healthy instances receive traffic. Terraform-defined auto-healing will replace unhealthy tasks.
Cost Optimization: The architecture uses Fargate (no EC2 management) and right-sizes resources (e.g., t3.micro for RDS by default) to minimize cost. The application’s recommendations endpoint also exemplifies cost-saving insights (e.g., detecting underutilized instances).
How to Extend
Frontend Dashboard: This backend can be paired with a frontend (perhaps a React app or Grafana dashboard) to visualize cost metrics over time.
Real Cost Data: Integration with AWS Cost Explorer or CloudWatch could replace the static data with real cost and usage information, making the recommendations more impactful.
Alerts & Notifications: AWS budgets or custom CloudWatch alarms could be added to notify when cost thresholds are exceeded, using this app as a webhook or integrating AWS SNS.
Testing: While the project is a demo, adding unit tests for the FastAPI routes and integration tests for the Terraform modules (e.g., using Terratest) would improve reliability.
Getting Help
For any issues with deployment or questions about the project, please open an issue in this repository. Contributions and improvements are welcome – this project is intended as a learning showcase for DevOps and Cloud engineering practices.

 Author Bilal Khawaja Cloud Engineer | AWS Certified Solutions Architect Associate
🔗 www.linkedin.com/in/bilal-khawaja-65b883243 
