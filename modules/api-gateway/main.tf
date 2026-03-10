data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "api" {
  name = var.api_name
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name            = "${var.api_name}-cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.api.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [var.cognito_user_pool_arn]
  identity_source = "method.request.header.Authorization"
}

# /greet
resource "aws_api_gateway_resource" "greet" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "greet"
}

resource "aws_api_gateway_method" "greet_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.greet.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_integration" "greet_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.greet.id
  http_method             = aws_api_gateway_method.greet_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.greeter_lambda_arn}/invocations"
}

# /dispatch
resource "aws_api_gateway_resource" "dispatch" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "dispatch"
}

resource "aws_api_gateway_method" "dispatch_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.dispatch.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_integration" "dispatch_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.dispatch.id
  http_method             = aws_api_gateway_method.dispatch_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.dispatcher_lambda_arn}/invocations"
}

# Permission for API Gateway to invoke Greeter Lambda
resource "aws_lambda_permission" "allow_apigw_greeter" {
  statement_id  = "AllowExecutionFromAPIGatewayGreeter"
  action        = "lambda:InvokeFunction"
  function_name = var.greeter_lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.greet_method.http_method}${aws_api_gateway_resource.greet.path}"
}

# Permission for API Gateway to invoke Dispatcher Lambda
resource "aws_lambda_permission" "allow_apigw_dispatcher" {
  statement_id  = "AllowExecutionFromAPIGatewayDispatcher"
  action        = "lambda:InvokeFunction"
  function_name = var.dispatcher_lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.dispatch_method.http_method}${aws_api_gateway_resource.dispatch.path}"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_authorizer.cognito_authorizer,
    aws_api_gateway_method.greet_method,
    aws_api_gateway_integration.greet_integration,
    aws_api_gateway_method.dispatch_method,
    aws_api_gateway_integration.dispatch_integration
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.greet.id,
      aws_api_gateway_method.greet_method.id,
      aws_api_gateway_integration.greet_integration.id,
      aws_api_gateway_resource.dispatch.id,
      aws_api_gateway_method.dispatch_method.id,
      aws_api_gateway_integration.dispatch_integration.id,
      aws_api_gateway_authorizer.cognito_authorizer.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = var.stage_name
}