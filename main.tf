terraform {
  required_version = ">=1.1.4"

  required_providers {
    aws = {
      version = ">= 5.6"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "state-version-tech"
    key = "terraform-lambda-auth-state"
    region = "us-east-1"
  }
}