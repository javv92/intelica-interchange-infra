terraform {
  backend "s3" {
    bucket = "terraform-backend-861276092327"
    key    = "intelica-interchange/infra/dev/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.42"
    }
  }
}


provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = var.global_tags
  }
}