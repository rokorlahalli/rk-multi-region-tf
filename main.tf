#COGNITO
module "cognito" {
    providers = {
      aws = aws.us
    }
    source = "./modules/cognito"

    region = "us-east-1"
    user_pool_name = "unleash-assessment-user-pool"
    user_pool_client = "unleash-assessment-client"

    tags = {
      Project = "aws-assessment"
    }
}
output "user_pool_id" {
  value = module.cognito.user_pool_id
}

output "user_pool_client_id" {
  value = module.cognito.user_pool_client_id
}

output "issuer_url" {
  value = module.cognito.issuer_url
}

# Greeter LAMBDA

#US-EAST-1

module "us_greeter_lambda" {
  source = "./modules/greeter_lambda"
  function_name = "us-greeter-lambda"
  lambda_execution_role = "us-greeter-lambda-role"
  sns_topic_arn      = var.sns_topic_arn
  dynamodb_table_name = module.us_dynamodb.dynamodb_table_name

  greeter_zip_file    = "greeter.zip"
  greeter_runtime     = "nodejs22.x"       
  greeter_handler     = "index.handler"        

  providers = {
    aws = aws.us
  }
  depends_on = [ module.us_dynamodb ]
}



#EU-WEST-1

module "eu_greeter_lambda" {
  source = "./modules/greeter_lambda"
  function_name = "eu-greeter-lambda"
  lambda_execution_role = "eu-greeter-lambda-role"
  sns_topic_arn      = var.sns_topic_arn
  dynamodb_table_name = module.eu_dynamodb.dynamodb_table_name

  greeter_zip_file    = "greeter.zip"
  greeter_runtime     = "nodejs22.x"       
  greeter_handler     = "index.handler"        

  providers = {
    aws = aws.eu
  }
  depends_on = [ module.eu_dynamodb ]
}

#DYNAMODB

#US
module "us_dynamodb" {
  source = "./modules/dynamodb"
  
  dynamodb_table_name = "us-greeting-logs"
  
  tags = {
    Project = "aws-assessment"
  }

  providers = {
    aws = aws.us  
  }
}


#EU
module "eu_dynamodb" {
  source = "./modules/dynamodb"

  dynamodb_table_name = "eu-greeting-logs"

  tags = {
    Project = "aws-assessment"
  }

  providers = {
    aws = aws.eu 
  }
}

#ECS

data "aws_vpc" "default_us" {
  provider = aws.us
  default  = true
}

data "aws_subnets" "us_subnets" {
  provider = aws.us

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_us.id]
  }
}

module "us_ecs" {

  source = "./modules/ecs"

  cluster_name = "unleash-cluster-us"
  task_family  = "sns-task-us"

  sns_topic_arn = var.sns_topic_arn

  email      = var.email
  repo_url   = var.repo_url
  region_name = "us-east-1"

  vpc_id     = data.aws_vpc.default_us.id
  subnet_ids = data.aws_subnets.us_subnets.ids

  providers = {
    aws = aws.us
  }
}

data "aws_vpc" "default_eu" {
  provider = aws.eu
  default  = true
}

data "aws_subnets" "eu_subnets" {
  provider = aws.eu

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_eu.id]
  }
}


module "eu_ecs" {

  source = "./modules/ecs"

  cluster_name = "unleash-cluster-eu"
  task_family  = "sns-task-eu"

  sns_topic_arn = var.sns_topic_arn

  email      = var.email
  repo_url   = var.repo_url
  region_name = "eu-west-1"

  vpc_id     = data.aws_vpc.default_eu.id
  subnet_ids = data.aws_subnets.eu_subnets.ids

  providers = {
    aws = aws.eu
  }
}

#Dispatcher Lambda
#US
module "us_dispatcher_lambda" {
  source = "./modules/dispatcher_lambda"

  dispatcher_zip_file      = "dispatcher.zip"
  dispatcher_function_name = "us-dispatcher-lambda"
  dispatcher_handler       = "index.handler"
  dispatcher_runtime       = "nodejs22.x"

  cluster_arn              = module.us_ecs.cluster_arn
  task_definition_arn      = module.us_ecs.task_definition_arn
  subnet_ids               = data.aws_subnets.us_subnets.ids
  security_group_id        = module.us_ecs.security_group_id
  ecs_task_execution_role_arn = module.us_ecs.execution_role_arn
  ecs_task_role_arn           = module.us_ecs.task_role_arn

  providers = {
    aws = aws.us
  }
}

#EU
module "eu_dispatcher_lambda" {
  source = "./modules/dispatcher_lambda"

  dispatcher_zip_file      = "dispatcher.zip"
  dispatcher_function_name = "eu-dispatcher-lambda"
  dispatcher_handler       = "index.handler"
  dispatcher_runtime       = "nodejs22.x"

  cluster_arn              = module.eu_ecs.cluster_arn
  task_definition_arn      = module.eu_ecs.task_definition_arn
  subnet_ids               = data.aws_subnets.eu_subnets.ids
  security_group_id        = module.eu_ecs.security_group_id
  ecs_task_execution_role_arn = module.eu_ecs.execution_role_arn
  ecs_task_role_arn           = module.eu_ecs.task_role_arn

  providers = {
    aws = aws.eu
  }
}

#API GATEWAY
#US
module "us_api_gateway" {
  source = "./modules/api-gateway"

  api_name                    = "unleash-api-us"
  stage_name                  = "prod"
  cognito_user_pool_arn       = module.cognito.user_pool_arn

  greeter_lambda_arn   = module.us_greeter_lambda.greeter_lambda_function_arn
  greeter_lambda_function_name = module.us_greeter_lambda.greeter_lambda_function_name

  dispatcher_lambda_arn   = module.us_dispatcher_lambda.dispatcher_lambda_function_arn
  dispatcher_lambda_function_name = module.us_dispatcher_lambda.dispatcher_lambda_function_name

  providers = {
    aws = aws.us
  }
}

#EU

module "eu_api_gateway" {
  source = "./modules/api-gateway"

  api_name                    = "unleash-api-eu"
  stage_name                  = "prod"
  cognito_user_pool_arn       = module.cognito.user_pool_arn

  greeter_lambda_arn   = module.eu_greeter_lambda.greeter_lambda_function_arn
  greeter_lambda_function_name = module.eu_greeter_lambda.greeter_lambda_function_name

  dispatcher_lambda_arn   = module.eu_dispatcher_lambda.dispatcher_lambda_function_arn
  dispatcher_lambda_function_name = module.eu_dispatcher_lambda.dispatcher_lambda_function_name

  providers = {
    aws = aws.eu
  }
}
