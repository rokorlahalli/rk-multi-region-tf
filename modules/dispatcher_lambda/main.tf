resource "aws_lambda_function" "dispatcher" {
  filename         = var.dispatcher_zip_file
  function_name    = var.dispatcher_function_name
  role             = aws_iam_role.dispatcher_lambda_role.arn
  handler          = var.dispatcher_handler
  runtime          = var.dispatcher_runtime

  environment {
    variables = {
      CLUSTER_ARN         = var.cluster_arn
      TASK_DEFINITION_ARN = var.task_definition_arn
      SUBNET_IDS          = join(",", var.subnet_ids)
      SECURITY_GROUP_ID   = var.security_group_id
    }
  }

  depends_on = [
    aws_iam_role.dispatcher_lambda_role
  ]
}

resource "aws_iam_role" "dispatcher_lambda_role" {
  name = var.dispatcher_function_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "dispatcher_ecs_policy" {
  name = "${var.dispatcher_function_name}-ecs-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["ecs:RunTask"]
        Resource = var.task_definition_arn
      },
      {
        Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = [
          var.ecs_task_execution_role_arn,
          var.ecs_task_role_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dispatcher_ecs_attach" {
  role       = aws_iam_role.dispatcher_lambda_role.name
  policy_arn = aws_iam_policy.dispatcher_ecs_policy.arn
}