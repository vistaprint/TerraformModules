output "names" {
  value = ["${aws_dynamodb_table.table.*.name}"]
}
