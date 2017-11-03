output "depends_id" {
  value = "${md5(
    join("", aws_api_gateway_integration_response.integration_responses.*.id)
  )}"
}
