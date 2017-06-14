output "path_resource_id" {
  value = [
    "${aws_api_gateway_resource.path1.id}",
    "${aws_api_gateway_resource.path2.id}",
    "${aws_api_gateway_resource.path3.id}",
    "${aws_api_gateway_resource.path4.id}"
  ]
}

output "path_part" {
  value = [
    "${aws_api_gateway_resource.path1.path_part}",
    "${aws_api_gateway_resource.path2.path_part}",
    "${aws_api_gateway_resource.path3.path_part}",
    "${aws_api_gateway_resource.path4.path_part}"
  ]
}
