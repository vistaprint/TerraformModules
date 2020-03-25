resource "aws_api_gateway_gateway_response" "response_4xx" {
  rest_api_id   = var.api
  status_code   = "500"
  response_type = "DEFAULT_4XX"
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_gateway_response" "access_denied" {
  rest_api_id   = var.api
  status_code   = "403"
  response_type = "ACCESS_DENIED"
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_gateway_response" "bad_request_parameters" {
  rest_api_id   = var.api
  status_code   = "400"
  response_type = "BAD_REQUEST_PARAMETERS"
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_gateway_response" "bad_request_body" {
  rest_api_id   = var.api
  status_code   = "400"
  response_type = "BAD_REQUEST_BODY"
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_gateway_response" "expired_token" {
  rest_api_id   = var.api
  status_code   = "403"
  response_type = "EXPIRED_TOKEN"
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_gateway_response" "invalid_api_key" {
  rest_api_id   = var.api
  status_code   = "403"
  response_type = "INVALID_API_KEY"
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_gateway_response" "invalid_signature" {
  rest_api_id   = var.api
  status_code   = "403"
  response_type = "INVALID_SIGNATURE"
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_gateway_response" "missing_authentication_token" {
  rest_api_id   = var.api
  status_code   = "404"
  response_type = "MISSING_AUTHENTICATION_TOKEN"
  response_templates = {
    "application/json" = "{\"message\":\"Not found\"}"
  }
}

resource "aws_api_gateway_gateway_response" "quota_exceeded" {
  rest_api_id   = var.api
  status_code   = "429"
  response_type = "QUOTA_EXCEEDED"
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_gateway_response" "request_too_large" {
  rest_api_id   = var.api
  status_code   = "413"
  response_type = "REQUEST_TOO_LARGE"
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_gateway_response" "resource_not_found" {
  rest_api_id   = var.api
  status_code   = "404"
  response_type = "RESOURCE_NOT_FOUND"
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_gateway_response" "throttled" {
  rest_api_id   = var.api
  status_code   = "429"
  response_type = "THROTTLED"
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_gateway_response" "unauthorized" {
  rest_api_id   = var.api
  status_code   = "401"
  response_type = "UNAUTHORIZED"
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_gateway_response" "response_unsupported_media_type" {
  rest_api_id   = var.api
  status_code   = "415"
  response_type = "UNSUPPORTED_MEDIA_TYPE"
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}
