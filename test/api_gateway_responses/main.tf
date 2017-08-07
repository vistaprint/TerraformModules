provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

### API ###

resource "aws_api_gateway_rest_api" "api" {
 name = "${var.prefix}ApiGatewayResponses"
}

module "method" {
  source = "../../modules/api_method"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${aws_api_gateway_rest_api.api.root_resource_id}"
  request = {
    type = "MOCK"
    content_type = "application/json"
    template = <<EOF
{"statusCode": 200}
EOF
  }
  responses = {
    "200" = {
      content_type = "text/plain"
      selection_pattern = ""
      template = "OK"
    }
  }
}

module "gateway_responses" {
  source = "../../modules/api_gateway_responses"
  api    = "${aws_api_gateway_rest_api.api.id}"
}

### Deployment ###

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = ["module.method", "module.gateway_responses"]
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "Test"

  provisioner "local-exec" {
    command = "wait_for_url ${aws_api_gateway_deployment.deployment.invoke_url} 120"
  }
}

output "api_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}"
}
