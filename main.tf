terraform {
  required_version = ">=1.1.4"

  required_providers {
    aws = {
      version = ">= 5.6"
      source  = "hashicorp/aws"
    }
  }
}