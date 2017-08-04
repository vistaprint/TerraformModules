provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

### API ###

resource "aws_api_gateway_rest_api" "api" {
 name = "${var.prefix}ApiMethod"
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
{"statusCode": #if($input.params('q')=="existing")200#{else}404#end}
EOF
  }
  querystrings = {
    p = false
    q = true
  }
  responses = {
    "200" = {
      content_type = "text/plain"
      selection_pattern = ""
      template = "Found"
    }
    "404" = {
      content_type = "text/plain"
      selection_pattern = "404"
      template = "Not found"
    }
  }
}

### Test for headers ###

module "path" {
  source = "../../modules/api_path/path1"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path   = ["redirect"]
}

module "redirect_method" {
  source = "../../modules/api_method"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${element(module.path.path_resource_id, 0)}"
  request = {
    type = "MOCK"
    content_type = "application/json"
    template = <<EOF
{"statusCode": 301}
EOF
  }
  headers = { Location = "http://www.example.com" }
  responses = {
    "301" = {
      selection_pattern = ""
    }
  }
}

### Test for cache key parameters ###

module "param" {
  source = "../../modules/api_path/path2"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path   = ["caching", "{param}"]
}

module "caching_method" {
  source = "../../modules/api_method"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${element(module.param.path_resource_id, 1)}"
  request = {
    type = "MOCK"
    content_type = "application/json"
    template = <<EOF
{"statusCode": #if($input.params('q')=="existing")200#{else}404#end}
EOF
  }
  querystrings = {
    q = true
    p = true
  }
  cache_key_parameters = ["path.param", "querystring.q"]
  responses = {
    "200" = {
      content_type = "text/plain"
      selection_pattern = ""
      template = "Found"
    }
    "404" = {
      content_type = "text/plain"
      selection_pattern = "404"
      template = "Not found"
    }
  }
}

### Test for passthrough behavior ###

module "passthrough" {
  source = "../../modules/api_path/path1"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path   = ["passthrough"]
}

module "passthrough_method" {
  source = "../../modules/api_method"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${element(module.passthrough.path_resource_id, 0)}"
  request = {
    type = "MOCK"
    content_type = "application/json"
    template = <<EOF
{"statusCode": 200}
EOF
  }
  passthrough_behavior = "NEVER"
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
  depends_on = ["module.method", "module.redirect_method", "module.caching_method", "module.passthrough"]
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "Test"

  provisioner "local-exec" {
    command = "wait_for_url ${aws_api_gateway_deployment.deployment.invoke_url} 10"
  }

  provisioner "local-exec" {
    command = "wait_for_url ${aws_api_gateway_deployment.deployment.invoke_url}/redirect 10"
  }

  provisioner "local-exec" {
    command = "wait_for_url ${aws_api_gateway_deployment.deployment.invoke_url}/caching/foo 10"
  }

  provisioner "local-exec" {
    command = "wait_for_url ${aws_api_gateway_deployment.deployment.invoke_url}/passthrough 10"
  }
}

output "api_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}"
}
