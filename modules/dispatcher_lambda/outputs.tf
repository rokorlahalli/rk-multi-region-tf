output "dispatcher_lambda_function_name" {
  value       = aws_lambda_function.dispatcher.function_name
  description = "The name of the Dispatcher Lambda function"
}

output "dispatcher_lambda_function_arn" {
  value       = aws_lambda_function.dispatcher.arn
  description = "The ARN of the Dispatcher Lambda function"
}