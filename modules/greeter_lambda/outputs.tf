output "greeter_lambda_function_name" {
  value       = aws_lambda_function.greeter.function_name
  description = "The name of the Greeter Lambda function"
}

output "greeter_lambda_function_arn" {
  value       = aws_lambda_function.greeter.arn
  description = "The ARN of the Greeter Lambda function"
}