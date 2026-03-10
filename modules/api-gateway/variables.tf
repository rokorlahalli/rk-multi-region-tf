variable "api_name" {
  type = string
}

variable "stage_name" {
  type = string
}

variable "cognito_user_pool_arn" {
  type = string
}

variable "greeter_lambda_arn" {
  type = string
}

variable "greeter_lambda_function_name" {
  type = string
}

variable "dispatcher_lambda_arn" {
  type = string
}

variable "dispatcher_lambda_function_name" {
  type = string
}