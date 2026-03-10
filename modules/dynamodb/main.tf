resource "aws_dynamodb_table" "greeting_logs" {
    name = var.dynamodb_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "email"
    range_key = "timestamp"

    attribute {
      name = "email"
      type = "S"
    }

    attribute {
      name = "timestamp"
      type = "S"
    }

    tags = var.tags
}