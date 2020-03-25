variable "api" {
  description = "Identifier of the API to use."
}

variable "parent" {
  description = "Identifier of the parent resource from which the endpoint will hang."
}

variable "path" {
  description = "Path resource names (path1/path2/path3)"
  type        = list(string)
}
