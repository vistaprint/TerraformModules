output "api_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}

output "stage_name" {
  value = aws_api_gateway_stage.stages.*.stage_name
}
