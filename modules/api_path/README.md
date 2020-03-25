This module creates a set of path resources under a given path.

It allows for a multilevel path to be created. Currently supports endpoints up to five path levels deep.

The module is actually a set of modules that allow users to instatiate path resources with variable depth. For instance, an endpoint with two path resources (`/hello/{name}`) should be created as:

```hcl
module "path" {
  source = "git::https://github.com/vistaprint/terraformmodules.git//modules/api_path/path2"
  path   = ["hello", "{name}"]
  # ...
}

module "method" {
  source = "git::https://github.com/vistaprint/terraformmodules.git//modules/api_method"
  parent = element(module.path.path_resource_id, 1)
  # ...
}
```

As another example, an endpoint with three path resources (`/hello/{language}/{name}`) should be created as:

```hcl
module "path" {
  source = "git::https://github.com/vistaprint/terraformmodules.git//modules/api_path/path3"
  path   = ["hello", "{language}", "{name}"]
  # ...
}
```

See the `variables.tf` file in the module folder for more information on the module parameters.

# Example

```hcl
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.prefix}ApiPathModule"
  description = "Sample API for API path module"
}

module "path" {
  source = "git::https://github.com/vistaprint/terraformmodules.git//modules/api_path/path2"
  api    = aws_api_gateway_rest_api.api.id
  parent = aws_api_gateway_rest_api.api.root_resource_id
  path   = ["hello", "{name}"]
}

module "method" {
  source = "git::https://github.com/vistaprint/terraformmodules.git//modules/api_method"
  api    = aws_api_gateway_rest_api.api.id
  parent = element(module.path.path_resource_id, 1)
  request = {
    type = "AWS"
    uri  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda}/invocations" 
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
```
