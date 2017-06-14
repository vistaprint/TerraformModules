resource "aws_api_gateway_resource" "path1" {
  rest_api_id = "${var.api}"
  parent_id   = "${var.parent}"
  path_part   = "${element(var.path, 0)}"
}

resource "aws_api_gateway_resource" "path2" {
  rest_api_id = "${var.api}"
  parent_id   = "${aws_api_gateway_resource.path1.id}"
  path_part   = "${element(var.path, 1)}"
}

resource "aws_api_gateway_resource" "path3" {
  rest_api_id = "${var.api}"
  parent_id   = "${aws_api_gateway_resource.path2.id}"
  path_part   = "${element(var.path, 2)}"
}

resource "aws_api_gateway_resource" "path4" {
  rest_api_id = "${var.api}"
  parent_id   = "${aws_api_gateway_resource.path3.id}"
  path_part   = "${element(var.path, 3)}"
}
