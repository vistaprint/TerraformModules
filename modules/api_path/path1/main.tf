resource "aws_api_gateway_resource" "path1" {
  rest_api_id = "${var.api}"
  parent_id   = "${var.parent}"
  path_part   = "${element(var.path, 0)}"
}
