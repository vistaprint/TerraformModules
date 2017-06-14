output "path_resource_id" {
  value = [
    "${aws_api_gateway_resource.path1.id}"
  ]
}

output "path_part" {
  value = [
    "${aws_api_gateway_resource.path1.path_part}"
  ]
}
