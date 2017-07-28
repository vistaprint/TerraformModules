resource "aws_dynamodb_table" "table" {
  count          = "${length(var.table_info)}"
  name           = "${lookup(var.table_info[count.index], "name")}"
  read_capacity  = "${lookup(var.table_info[count.index], "read_capacity", "1")}"
  write_capacity = "${lookup(var.table_info[count.index], "write_capacity", "1")}"
  hash_key       = "ItemKey"

  attribute {
    name = "ItemKey"
    type = "S"
  }

  tags = "${var.tags}"
}
