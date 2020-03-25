provider "aws" {
  profile = var.profile
  region  = var.region
}

data "aws_caller_identity" "current" {}

### API ###

resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.prefix}ApiLambdaModule"
  description = "Sample API for lambda module"
}

module "hello_endpoint" {
  source = "../../modules/api_path/path2"
  api    = aws_api_gateway_rest_api.api.id
  parent = aws_api_gateway_rest_api.api.root_resource_id
  path   = ["hello", "{name}"]
}

module "hello_endpoint_external_role" {
  source = "../../modules/api_path/path2"
  api    = aws_api_gateway_rest_api.api.id
  parent = aws_api_gateway_rest_api.api.root_resource_id
  path   = ["hello-external-role", "{name}"]
}

module "printvars_endpoint" {
  source = "../../modules/api_path/path2"
  api    = aws_api_gateway_rest_api.api.id
  parent = aws_api_gateway_rest_api.api.root_resource_id
  path   = ["printvar", "{name}"]
}

module "hello_method" {
  source = "../../modules/api_method"
  api    = aws_api_gateway_rest_api.api.id
  parent = element(module.hello_endpoint.path_resource_id, 1)

  request = {
    type = "AWS"
    uri  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${module.lambdas.lambda_arns["LambdaTestHello"]}/invocations"

    template = <<EOF
{
  "name": "$input.params('name')"
}
EOF
  }

  responses = {
    "200" = {
      selection_pattern = ""
      template          = "$input.path('$.Result')"
      content_type      = "text/plain"
    }
  }
}

module "hello_method_external_role" {
  source = "../../modules/api_method"
  api    = aws_api_gateway_rest_api.api.id
  parent = element(module.hello_endpoint_external_role.path_resource_id, 1)

  request = {
    type = "AWS"
    uri  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${module.lambdas_with_external_role.lambda_arns["LambdaTestHelloExternalRole"]}/invocations"

    template = <<EOF
{
  "name": "$input.params('name')"
}
EOF
  }

  responses = {
    "200" = {
      selection_pattern = ""
      template          = "$input.path('$.Result')"
      content_type      = "text/plain"
    }
  }
}

module "printvars_method" {
  source = "../../modules/api_method"
  api    = aws_api_gateway_rest_api.api.id
  parent = element(module.printvars_endpoint.path_resource_id, 1)

  request = {
    type = "AWS"
    uri  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${module.lambdas.lambda_arns["LambdaTestPrintVars"]}/invocations"

    template = <<EOF
{
  "name": "$input.params('name')"
}
EOF
  }

  responses = {
    "200" = {
      selection_pattern = ""
      template          = "$input.path('$.Result')"
      content_type      = "text/plain"
    }
  }
}

### Lambda ###

module "lambdas" {
  source = "../../modules/lambda"

  lambda_file = "sample_lambda.zip"

  functions = {
    LambdaTestHello = {
      handler = "package.say_hello"
    }

    LambdaTestPrintVars = {
      handler = "package.print_vars"
    }
  }

  env_vars = {
    foo = "FOO"
    bar = "BAR"
  }

  memory_size = "256"

  permissions = [
    {
      principal    = "apigateway.amazonaws.com"
      statement_id = "AllowExecutionFromAPIGateway"
      source_arn   = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/GET/*/*"
    },
  ]

  prefix  = var.prefix
  runtime = "python3.6"
}

resource "aws_iam_role" "common_iam_for_lambda" {
  name = "${var.prefix}common_iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

module "lambdas_with_external_role" {
  source = "../../modules/lambda"

  lambda_file = "sample_lambda.zip"

  functions = {
    LambdaTestHelloExternalRole = {
      handler = "package.say_hello"
    }
  }

  create_role = false
  role_arn    = aws_iam_role.common_iam_for_lambda.arn

  permissions = [
    {
      principal    = "apigateway.amazonaws.com"
      statement_id = "AllowExecutionFromAPIGateway"
      source_arn   = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/GET/*/*"
    },
  ]

  prefix  = var.prefix
  runtime = "python3.6"
}

### Deployment ###

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    "module.hello_method",
    "module.hello_method_external_role",
    "module.printvars_method",
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "Prod"

  provisioner "local-exec" {
    command = "wait_for_url ${aws_api_gateway_deployment.deployment.invoke_url}/hello/foo 600"
  }

  provisioner "local-exec" {
    command = "wait_for_url ${aws_api_gateway_deployment.deployment.invoke_url}/hello-external-role/foo 600"
  }

  provisioner "local-exec" {
    command = "wait_for_url ${aws_api_gateway_deployment.deployment.invoke_url}/printvar/foo 600"
  }
}

output "api_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}

# This is just to test that the lambda_names output is created as expected.
output "lambda_names" {
  value = module.lambdas.lambda_names
}
