provider "aws" {
  profile    = "${var.profile}"
  region     = "${var.region}"
}

data "aws_caller_identity" "current" {}

### API ###

resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.prefix}ApiLambdaModule"
  description = "Sample API for lambda module"
}

module "hello_endpoint" {
  source = "../../modules/api_path/path2"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path   = ["hello", "{name}"]
}

module "goodbye_endpoint" {
  source = "../../modules/api_path/path2"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path   = ["goodbye", "{name}"]
}

module "hello_method" {
  source = "../../modules/api_method"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${element(module.hello_endpoint.path_resource_id, 1)}"
  request = {
    type = "AWS"
    uri  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${module.lambdas.lambda_arns[0]}/invocations" 
    template = <<EOF
{
  "name": "$input.params('name')"
}
EOF
  }
  responses = {
    "200" = {
      selection_pattern = ""
      template = "#set($inputRoot = $input.path('$'))$inputRoot.Result"
      content_type = "text/plain"
    }
  }
}

module "goodbye_method" {
  source = "../../modules/api_method"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${element(module.goodbye_endpoint.path_resource_id, 1)}"
  request = {
    type = "AWS"
    uri  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${module.lambdas.lambda_arns[1]}/invocations" 
    template = <<EOF
{
  "name": "$input.params('name')"
}
EOF
  }
  responses = {
    "200" = {
      selection_pattern = ""
      template = "#set($inputRoot = $input.path('$'))$inputRoot.Result"
      content_type = "text/plain"
    }
  }
}

### Lambda ###

module "lambdas" {
  source = "../../modules/lambda"

  lambda_file = "sample_lambda.zip"
  function_names_and_handlers = {
    LambdaModuleTest1 = "package.say_hello"
    LambdaModuleTest2 = "package.say_goodbye"
  }
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/GET/*/*"
  statement_id = "AllowExecutionFromAPIGateway"
  principal = "apigateway.amazonaws.com"
  prefix = "${var.prefix}"
  runtime = "python3.6"
}

### Deployment ###

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = ["module.hello_method", "module.goodbye_method"]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "Prod"

  provisioner "local-exec" {
    command = "ruby ../../build/wait_for_url.rb ${aws_api_gateway_deployment.deployment.invoke_url}/hello/foo"
  }

  provisioner "local-exec" {
    command = "ruby ../../build/wait_for_url.rb ${aws_api_gateway_deployment.deployment.invoke_url}/goodbye/foo"
  }
}

output "api_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}"
}
