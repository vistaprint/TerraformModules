This module creates an OPTIONS method, and configures the request and response steps of an API gateway to enable CORS for a given endpoint.

The module accepts two input variables:

* `api`: the identifier of the API where the method will be created.
* `parent`: the identifier of the parent resource from which the method will hang.

To effectively enable CORS for a given endpoint, in addition to creating an OPTIONS method, it is also required to add a header to the GET method (defined elsewhere). See the example below for an example on how to do this.

# Example

```
resource "aws_api_gateway_rest_api" "api" {
 name = "TestApiCors"
}

module "method" {
  source = "git::https://github.com/betabandido/terraformmodules.git//modules/api_method"
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
  headers = { Access-Control-Allow-Origin = "*" }
}

module "options" {
  source = "git::https://github.com/betabandido/terraformmodules.git//modules/api_cors"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${aws_api_gateway_rest_api.api.root_resource_id}"
}
```
