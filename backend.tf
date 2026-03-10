terraform {
  backend "s3" {
    bucket = "aws-assess-state-bucket-030326"
    key    = "terraform-tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}