resource "aws_ecs_cluster" "cluster" {
    name = var.cluster_name  
}

resource "aws_security_group" "ecs_sg" {
    name = "${var.cluster_name}-sg"
    vpc_id = var.vpc_id
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.cluster_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.cluster_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "sns_publish_policy" {

  name = "${var.cluster_name}-sns-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.sns_topic_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sns_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "${var.cluster_name}-sns-publisher"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "task" {

  family                   = var.task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
  {
    name  = "sns-publisher"
    image = "amazon/aws-cli"

    command = [
      "sns",
      "publish",
      "--region",
      "us-east-1",
      "--topic-arn",
      var.sns_topic_arn,
      "--message",
      jsonencode({
        email  = var.email
        source = "ECS"
        region = var.region_name
        repo   = var.repo_url
      })
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
        awslogs-region        = var.region_name
        awslogs-stream-prefix = "ecs"
      }
    }

    essential = true
  }
])
depends_on = [ aws_cloudwatch_log_group.ecs_logs ]
}

