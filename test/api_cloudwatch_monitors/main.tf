provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

### API ###

resource "aws_api_gateway_rest_api" "api" {
  name = "${var.prefix}ApiCloudWatchMonitors"
}

### Test for query strings ###

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

### Deployment ###

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = ["module.method"]
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "Test"

  provisioner "local-exec" {
    command = "wait_for_url ${aws_api_gateway_deployment.deployment.invoke_url} 10"
  }
}

output "api_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}"
}

### Alarms ###

module "sample_monitors" {
  source     = "../../modules/api_cloudwatch_monitors"
  api_name   = "${aws_api_gateway_rest_api.api.name}"
  stage_name = "Test"
  # TODO: remove once https://github.com/hashicorp/terraform/issues/15471 gets fixed.
  alarm_count = 4
  alarms = {
    "4XXError" = {
      threshold = 100
    }
    "5XXError" = {
      threshold = 25
    }
    "Latency" = {
      statistic = "Average"
    }
    "CacheMissCount" = {}
  }
}
