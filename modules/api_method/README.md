This module creates an API gateway method under a given path.

See the `variables.tf` file in the module folder for more information on the module parameters. Most of these parameters are directly passed to the corresponding Terraform resource. The documentation for [integration](https://www.terraform.io/docs/providers/aws/r/api_gateway_integration.html) resources and [integration response](https://www.terraform.io/docs/providers/aws/r/api_gateway_integration_response.html) resources contains information on the module parameters such as `request.template` or `responses.template`.

# Example

```hcl
resource "aws_api_gateway_rest_api" "api" {
 name = "${var.prefix}ApiMethod"
}

module "sample_method" {
  source = "git::https://github.com/vistaprint/terraformmodules.git//modules/api_method"
  api    = aws_api_gateway_rest_api.api.id
  parent = aws_api_gateway_rest_api.api.root_resource_id
  querystrings = {
    q = true
  }
  request = {
    type = "MOCK"
    content_type = "application/json"
    template = <<EOF
{"statusCode": #if($input.params('q')=="existing")200#{else}404#end}
EOF
  }
  passthrough_behavior = "NEVER"
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
```

# Limitations

* Only works for `GET` methods

# Usage Guidelines

## Response Content Type

The default response content type is `application/json`, but this can be overridden by using the `response_content_type` variable (as shown in the example).
