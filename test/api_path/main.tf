provider "aws" {
  profile    = var.profile
  region     = var.region
}

data "aws_caller_identity" "current" {}

### API ###

resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.prefix}ApiPathModule"
  description = "Sample API for API path module"
}

module "path" {
  source = "../../modules/api_path/path2"
  api    = aws_api_gateway_rest_api.api.id
  parent = aws_api_gateway_rest_api.api.root_resource_id
  path   = ["hello", "{name}"]
}

module "method" {
  source = "../../modules/api_method"
  api    = aws_api_gateway_rest_api.api.id
  parent = element(module.path.path_resource_id, 1)
  request = {
    type = "AWS"
    uri  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${module.lambda.lambda_arns["LambdaModuleTest1"]}/invocations" 
    template = <<EOF
{
  "name": "$input.params('name')"
}
EOF
  }
  responses = {
    "200" = {
      selection_pattern = ""
      template = "$input.path('$.Result')"
      content_type = "text/plain"
    }
  }
}

### Lambda ###

module "lambda" {
  source       = "../../modules/lambda"
  lambda_file  = "sample_lambda.zip"
  functions    = {LambdaModuleTest1 = { handler = "hello.say_hello" }}

  permissions = [
    {
      principal    = "apigateway.amazonaws.com"
      statement_id = "AllowExecutionFromAPIGateway"
      source_arn   = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/GET/*/*"
    }
  ]
  
  prefix       = var.prefix
  runtime      = "python3.6"
}

### Deployment ###

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = ["module.method"]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "Prod"

  provisioner "local-exec" {
    command = "wait_for_url ${aws_api_gateway_deployment.deployment.invoke_url}/hello/foo 600"
  }
}


output "api_path_parts" {
  value = module.path.path_part
}

output "api_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}