variable "lambda_file" {
  description = "The lambda zip file to upload to the functions."
}

variable "function_names_and_handlers" {
  type = "map"
  description = "A map of function names to the handler each function will invoke."
}

variable "source_arn" {
  description = "The source arn of the API that will invoke the lambda."
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

variable "statement_id" {
  description = "A unique statement identifier"
}

variable "principal" {
  description = "The principal who is getting this permission. e.g. s3.amazonaws.com"
}

variable "tags" {
  description = "Tags to apply to each lambda"
  type = "map"
}