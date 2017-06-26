resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = "${var.api}"
  description = "${var.description}"
  stage_name  = "${var.default_stage["name"]}"
  stage_description = "${var.default_stage["description"]}"
  variables = {
    depends_id = "${md5("${join("", var.depends_id)}")}"
  }
}

resource "aws_api_gateway_stage" "stages" {
  count = "${length(var.stages)}"
  rest_api_id   = "${var.api}"
  deployment_id = "${aws_api_gateway_deployment.deployment.id}"
  stage_name    = "${lookup(var.stages[count.index], "name")}"
  description   = "${lookup(var.stages[count.index], "description", "")}"

  cache_cluster_enabled = "${lookup(var.stages[count.index], "cache_cluster_enabled", false)}"
  cache_cluster_size    = 
    "${lookup(var.stages[count.index], "cache_cluster_enabled", false)
      ? lookup(var.stages[count.index], "cache_cluster_size", "0.5")
      : ""
    }"
}

resource "aws_api_gateway_method_settings" "method_settings" {
  count = "${length(var.stages)}"
  rest_api_id = "${var.api}"
  stage_name  = "${element(aws_api_gateway_stage.stages.*.stage_name, count.index)}"
  method_path = "*/*"
  settings {
    metrics_enabled      = "${lookup(var.stages[count.index], "metrics_enabled", false)}"
    caching_enabled      = "${lookup(var.stages[count.index], "cache_cluster_enabled", false)}"
    cache_ttl_in_seconds = "${lookup(var.stages[count.index], "cache_ttl_in_seconds", 300)}"
    logging_level        = "${lookup(var.stages[count.index], "logging_level", "OFF")}"
  }
}
