This module modifies gateway responses, so that any `4XX` error not listed in the [list of response types supported by API Gateway](http://docs.aws.amazon.com/apigateway/latest/developerguide/customize-gateway-responses.html) gets mapped to a `500` error.

A situation not supported in the previously mentioned list occurs when API Gateway responds with a "request template timeout" error. The status code returned by API Gateway is `400`. But, the timeout occurs with simple and valid requests. Therefore, it should not return a `4XX` response, as that suggests there was an issue in the request. By using this module it is possible to map that error to a `500` status code, which is more accurate as the error takes place in the server.

Additionally, as the API Gateway modules currently do not support using authentication tokens, this module maps the response type `MISSING_AUTHENTICATION_TOKEN` to `404` instead of `403`. The description for this response type states:

> The gateway response for a missing authentication token error, *including the cases when the client attempts to invoke an unsupported API method or resource*.

It is not intuitive to receive a missing authentication token when trying to access an unsupported (non-existing) endpoint (specially taking into account the API does not use tokens at all). Therefore, this module does not return the missing authentication token error, but a more intuitive "not found" error.

The module accepts a single input variable:

* `api`: the identifier of the API where the method will be created.

# Example

```hcl
resource "aws_api_gateway_rest_api" "api" {
 name = "TestApiGatewayResponses"
}

module "method" {
  source = "git::https://github.com/vistaprint/terraformmodules.git//modules/api_method"
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
  source = "git::https://github.com/vistaprint/terraformmodules.git//modules/api_gateway_responses"
  api    = "${aws_api_gateway_rest_api.api.id}"
}
```
