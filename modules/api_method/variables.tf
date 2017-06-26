variable "api" {
  description = "Identifier of the API to use."
}

variable "parent" {
  description = "Identifier of the parent resource from which the method will hang." 
}

variable "request" {
  description = <<EOF
Request information. The following arguments are supported:
  - type: integration input's type (AWS, MOCK) (required)
  - uri: input's URI (required if type is AWS)
  - content_type: content type of the request template (default: application/json)
  - template: request template
EOF
  type = "map"
}

variable "querystrings" {
  description = "Map containing the query strings (name => required)"
  type = "map"
  default = {}
}

variable "headers" {
  description = "Map containing the headers (name => value)"
  type = "map"
  default = {}
}

variable "cache_key_parameters" {
  description = "List containing the cache key parameters"
  type = "list"
  default = []
}

variable "responses" {
  description = <<EOF
Response information represented as a map where the keys are the status code
for each response and the values are maps containing the parameters for each
response.

The following arguments are supported to describe an individual response:
  - content_type: content type of the response template (default: application/json)
  - template: response template
EOF
  type = "map"
}
