terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  alias = "us"
}

provider "aws" {
  region     = "eu-west-1"
  alias = "eu"
}