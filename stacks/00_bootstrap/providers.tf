terraform {
  required_version = ">=1.13.1"
  # Bootstrap uses a local backend because the S3 backend doesn't exist yet!
  backend "local" {
    path = "bootstrap.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.14.1"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      ManagedBy = "Rafael-Team"
      Owner     = "Rafael.Andrade"
      Project   = "Dbk-Project"
      Region    = "us-east-2"
      Source    = "Terraform"
    }
  }
}
