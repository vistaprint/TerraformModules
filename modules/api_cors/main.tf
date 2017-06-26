resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${var.api}"
  resource_id   = "${var.parent}"
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id   = "${var.api}"
  resource_id   = "${var.parent}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  type = "MOCK"
  request_templates = { 
    "application/json" = <<EOF
{ "statusCode": 200 }
EOF
  }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  depends_on  = ["aws_api_gateway_integration.integration"]
  rest_api_id = "${var.api}"
  resource_id = "${var.parent}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_method_response" "response" {
  rest_api_id = "${var.api}"
  resource_id = "${var.parent}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
