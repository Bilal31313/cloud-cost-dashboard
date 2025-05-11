terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"   # stable 5.x series
    }
  }
}

provider "aws" {
  region = var.aws_region
}
