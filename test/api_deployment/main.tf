provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

data "aws_caller_identity" "current" {}

### API ###

resource "aws_api_gateway_rest_api" "api" {
  name = "${var.prefix}ApiDeploymentTest"
  description = "Sample API for deployment module"
}

module "method" {
  source = "../../modules/api_method"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${aws_api_gateway_rest_api.api.root_resource_id}"
  request = {
    type = "AWS"
    uri  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${module.lambdas.lambda_arns[0]}/invocations"
    template = <<EOF
{}
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

module "lambdas" {
  source = "../../modules/lambda"

  lambda_file = "lambda.zip"
  functions = { ApiDeploymentTestLambda = { handler = "lambda.handler" }}

  permission_count = 1
  permissions = [
    {
      principal    = "apigateway.amazonaws.com"
      statement_id = "AllowExecutionFromAPIGateway"
      source_arn   = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/GET/"
    }
  ]

  prefix = "${var.prefix}"
  runtime = "python3.6"
}

### Deployment ###

module "deployment" {
  source = "../../modules/api_deployment"
  api = "${aws_api_gateway_rest_api.api.id}"
  depends_id = ["${module.method.depends_id}"]
  default_stage = {
    name = "Default"
    description = "Default stage"
  }
  stages = [
    {
      name = "Cached"
      description = "Stage with caching and CloudWatch metrics enabled"
      cache_cluster_enabled = true
      metrics_enabled = true
    }
  ]
}

resource "null_resource" "wait_for_deployment" {
  depends_on = ["module.deployment"]

  provisioner "local-exec" {
    command = "wait_for_url ${module.deployment.api_url} 120"
  }

  provisioner "local-exec" {
    command = "wait_for_url ${replace(module.deployment.api_url, "/Default", "/Cached")} 600"
  }
}

output "stage_name" {
  value = "${module.deployment.stage_name}"
}

output "api_url" {
  value = "${module.deployment.api_url}"
}
