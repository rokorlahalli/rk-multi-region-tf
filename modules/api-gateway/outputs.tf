output "api_id" {
  value = aws_api_gateway_rest_api.api.id
}

output "invoke_url" {
  value = aws_api_gateway_stage.stage.invoke_url
}

output "greet_url" {
  value = "${aws_api_gateway_stage.stage.invoke_url}/greet"
}

output "dispatch_url" {
  value = "${aws_api_gateway_stage.stage.invoke_url}/dispatch"
}