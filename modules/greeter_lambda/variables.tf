variable "sns_topic_arn" {
  description = "The ARN of the SNS topic to publish to"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Greeter function"
  type        = string
}

variable "lambda_execution_role" {
  description = "role name"
  type        = string
}

variable "function_name" {
  description = "Name of the Function"
  type        = string
}

variable "greeter_zip_file" {
  description = "Path to the Greeter Lambda deployment zip file"
  type        = string
}

variable "greeter_runtime" {
  description = "The runtime environment for the Greeter Lambda function"
  type        = string
  default     = "nodejs14.x"
}

variable "greeter_handler" {
  description = "The handler for the Greeter Lambda function"
  type        = string
  default     = "index.handler"
}