# Project: NEXOPS - Enterprise AI-Native Platform Engineering Suite
# Component: Remote Backend Bootstrap (S3 + DynamoDB)

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" # Updated to Mumbai region to match your AWS Console
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "nexops-tf-state-bucket-ahmed-647"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly Block all Public Access to secure sensitive cloud architecture state logs
resource "aws_s3_bucket_public_access_block" "public_controls" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. DynamoDB Table for Distributed State Locking and Race Condition Prevention
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "nexops-tf-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "nexops-state-locks"
    Environment = "production"
  }
}