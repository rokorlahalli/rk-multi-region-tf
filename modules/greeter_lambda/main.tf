resource "aws_lambda_function" "greeter" {
    filename = var.greeter_zip_file
    function_name = var.function_name
    role = aws_iam_role.lambda_execution_role.arn
    handler = var.greeter_handler
    runtime = var.greeter_runtime
    environment {
      variables = {
        DYNAMODB_TABLE = var.dynamodb_table_name
        SNS_TOPIC_ARN  = var.sns_topic_arn
      }
    }
    depends_on = [ aws_iam_role.lambda_execution_role ]
  
}


resource "aws_iam_role" "lambda_execution_role" {
  name               = var.lambda_execution_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

# Attach policies using aws_iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "dynamodb_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "sns_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}
  
