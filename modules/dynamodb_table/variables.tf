variable "table_info" {
  description = <<EOF
A list of maps containing the information for each table. The following fields can be used:
  - name (required)
  - read_capacity  (defaults to 1)
  - write_capacity (defaults to 1)
EOF
  type = "list"
}

variable "tags"  {
  description = "Tags to add to the dynamodb tables."
  type = "map"
}