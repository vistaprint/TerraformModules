locals {
  default_content_type = "application/json"
  default_template     = "{}"
}

resource "aws_api_gateway_request_validator" "validator" {
  rest_api_id                 = "${var.api}"
  name                        = "${var.api}-${var.parent}-GET-req-validator"
  validate_request_parameters = true
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${var.api}"
  resource_id   = "${var.parent}"
  http_method   = "GET"
  authorization = "NONE"

  # The merging order matters as a query string that is also a cache key
  # parameter should not have its value unconditionally set to true,
  # but to the value provided by the user.
  request_parameters = "${merge(
    zipmap(
      formatlist("method.request.%s", var.cache_key_parameters),
      module.cache_key_parameters_values.list
    ),
    zipmap(
      formatlist("method.request.querystring.%s", keys(var.querystrings)),
      values(var.querystrings)
    )
  )}"

  request_validator_id = "${aws_api_gateway_request_validator.validator.id}"
}

# TODO: the integration step is split into two because
# integration_http_method should not be "POST" but an empty string cannot be
# passed either, as in:
# integration_http_method = "${var.request["type"] == "MOCK" ? "" : "POST"}"
# Once terraform 0.12 is released the concept of null values will be supported.
# That will allow us to stop splitting the integration step (as well as 
# removing the extra dependency in integration response step).

resource "aws_api_gateway_integration" "mock_integration" {
  count = "${var.request["type"] == "MOCK" ? 1 : 0}"

  rest_api_id          = "${var.api}"
  resource_id          = "${var.parent}"
  http_method          = "${aws_api_gateway_method.method.http_method}"
  type                 = "MOCK"
  cache_key_parameters = ["${formatlist("method.request.%s", var.cache_key_parameters)}"]

  request_templates = "${map(
      lookup(var.request, "content_type", local.default_content_type),
      lookup(var.request, "template", local.default_template)
    )}"

  passthrough_behavior = "${var.passthrough_behavior}"
}

resource "aws_api_gateway_integration" "integration" {
  count = "${var.request["type"] != "MOCK" ? 1 : 0}"

  rest_api_id             = "${var.api}"
  resource_id             = "${var.parent}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  type                    = "${var.request["type"]}"
  uri                     = "${contains(list("AWS", "HTTP"), var.request["type"]) ? lookup(var.request, "uri", "") : ""}"
  integration_http_method = "POST"
  cache_key_parameters    = ["${formatlist("method.request.%s", var.cache_key_parameters)}"]

  request_templates = "${map(
      lookup(var.request, "content_type", local.default_content_type),
      lookup(var.request, "template", local.default_template)
    )}"

  passthrough_behavior = "${var.passthrough_behavior}"
}

resource "aws_api_gateway_method_response" "responses" {
  count       = "${length(var.responses)}"
  rest_api_id = "${var.api}"
  resource_id = "${var.parent}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "${element(keys(var.responses), count.index)}"

  response_parameters = "${merge(
    map("method.response.header.Content-Type", true),
    zipmap(
      formatlist("method.response.header.%s", keys(var.headers)),
      module.response_headers_values.list
    )
  )}"
}

resource "aws_api_gateway_integration_response" "integration_responses" {
  count = "${length(var.responses)}"

  depends_on = [
    "aws_api_gateway_integration.mock_integration",
    "aws_api_gateway_integration.integration",
  ]

  rest_api_id       = "${var.api}"
  resource_id       = "${var.parent}"
  http_method       = "${aws_api_gateway_method.method.http_method}"
  status_code       = "${element(aws_api_gateway_method_response.responses.*.status_code, count.index)}"
  selection_pattern = "${lookup(var.responses[element(keys(var.responses), count.index)], "selection_pattern")}"

  response_templates = "${map(
    lookup(var.responses[element(keys(var.responses), count.index)], "content_type", local.default_content_type),
    lookup(var.responses[element(keys(var.responses), count.index)], "template", local.default_template)
  )}"

  response_parameters = "${merge(
    map(
      "method.response.header.Content-Type",
      "'${lookup(
        var.responses[element(keys(var.responses), count.index)],
        "content_type",
        local.default_content_type
      )}'"
    ),
    zipmap(
      formatlist("method.response.header.%s", keys(var.headers)),
      formatlist("'%s'", values(var.headers))
    )
  )}"
}

module "response_headers_values" {
  source = "../n_list"
  count  = "${length(var.headers)}"
  value  = "true"
}

module "cache_key_parameters_values" {
  source = "../n_list"
  count  = "${length(var.cache_key_parameters)}"
  value  = "true"
}
