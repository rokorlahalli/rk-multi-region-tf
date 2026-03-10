output "user_pool_id" {
  value       = aws_cognito_user_pool.my_user_pool.id
  description = "Cognito User Pool ID"
}

output "user_pool_arn" {
  value       = aws_cognito_user_pool.my_user_pool.arn
  description = "Cognito User Pool ARN"
}

output "user_pool_client_id" {
  value       = aws_cognito_user_pool_client.user_pool_client.id
  description = "Cognito User Pool Client ID"
}

# Issuer URL used by JWT validation / authorizers
output "issuer_url" {
  value       = "https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.my_user_pool.id}"
  description = "JWT issuer URL"
}