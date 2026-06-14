
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Isolate compute execution states separately inside our remote S3 storage cluster
  backend "s3" {
    bucket         = "nexops-tf-state-bucket-ahmed-647"
    key            = "compute/storage/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "nexops-tf-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}