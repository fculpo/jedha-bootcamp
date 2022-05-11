terraform {
  backend "s3" {
    profile        = "jedha"
    bucket         = "jedha-terraform-state"
    key            = "terraform.tfstate"
    dynamodb_table = "terraform-lock"
    region         = "eu-west-3"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region              = "eu-west-3"
  profile             = "jedha"
  allowed_account_ids = ["029426583701"]
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "jedha-terraform-state"

  tags = {
    Name = "jedha-terraform-state"
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
  hash_key       = "LockID"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}
