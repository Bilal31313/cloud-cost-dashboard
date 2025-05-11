variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-2"
}

variable "app_name" {
  description = "Base name for resource tags"
  type        = string
  default     = "cloud-cost-dashboard"
}

variable "ecr_repo_url" {
  description = "Fully-qualified ECR image URI (without :tag)"
  type        = string
  default     = "891377023859.dkr.ecr.eu-west-2.amazonaws.com/cloud-cost-dashboard"
}

variable "github_repo" {
  description = "GitHub org/repo for OIDC (e.g., Bilal/cloud-cost-dashboard)"
  type        = string
  default     = "Bilal/cloud-cost-dashboard"
}
