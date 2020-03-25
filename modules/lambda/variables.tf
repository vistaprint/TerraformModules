variable "lambda_file" {
  description = "The lambda zip file to upload to the functions."
}

variable "functions" {
  description = <<EOF
A map with the configuration for each function. The keys must contain the
function names, and the values are maps with the following valid fields:
  - handler: the handler the function will invoke
EOF
  type = "map"
}

variable "permissions" {
  description = <<EOF
A list of maps with the settings for each permission. The required settings are:
  - principal: The principal who is getting this permission (e.g., s3.amazonaws.com).
  - statement_id: A unique statement identifier.
  - source_arn: The source arn of the API that will invoke the lambda.
EOF
  type = "list"
  default = []
}

variable "policy" {
  description = "The policy to be used by the lambda role."
  default = ""
}

variable "runtime" {
  description = "The runtime to use."
}

variable "prefix" {
  description = "Prefix string for IAM roles, policies and function name. Defaults to empty string."
  default = ""
}

variable "timeout" {
  description = "The timeout the function should have. Defaults to 300."
  default = 300
}

variable "env_vars" {
  description = "A map that defines environment variables for the lambda function."
  type = "map"
  default = { dummy_ = "1" }
}

variable "tags" {
  description = "Tags to apply to each lambda"
  type = "map"
  default = {}
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128."
  default = "128"
}

variable "create_role" {
  description = "Whether to create a specific role and policy"

  default = true
}

variable "role_arn" {
  description = "Role ARN to use"

  default = ""
}
