variable "default_threshold" {
  default = 80
}

variable "default_evaluation_periods" {
  default = 2
}

variable "default_period" {
  default = 60
}

variable "default_comparison_operator" {
  default = "GreaterThanOrEqualToThreshold"
}

variable "default_statistic" {
  default = "Average"
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  # TODO: revert once https://github.com/hashicorp/terraform/issues/15471 gets fixed.
  #count               = "${length(var.alarms)}"
  count               = "${var.alarm_count}"
  alarm_name          = "${format("%s-%s-%s",
                          var.domain,
                          var.distribution_id,
                          element(keys(var.alarms), count.index))}"
  comparison_operator = "${lookup(
                          var.alarms[element(keys(var.alarms), count.index)],
                          "comparison_operator",
                          var.default_comparison_operator
                          )}"
  evaluation_periods  = "${lookup(
                          var.alarms[element(keys(var.alarms), count.index)],
                          "evaluation_periods",
                          var.default_evaluation_periods
                          )}"
  metric_name         = "${element(keys(var.alarms), count.index)}"
  namespace           = "AWS/CloudFront"
  period              = "${lookup(
                          var.alarms[element(keys(var.alarms), count.index)],
                          "period",
                          var.default_period
                          )}"
  statistic           = "${lookup(
                          var.alarms[element(keys(var.alarms), count.index)],
                          "statistic",
                          var.default_statistic
                          )}"
  threshold           = "${lookup(
                          var.alarms[element(keys(var.alarms), count.index)],
                          "threshold",
                          var.default_threshold
                          )}"
  
  dimensions {
    DistributionId = "${var.distribution_id}"
    Region   = "Global"
  }

  # For some reason Terraform aborted its execution when the result
  # of split() was an empty list (i.e., when no actions are given).
  # By using compact() the abort magically goes away.
  alarm_actions = ["${compact(split(",", lookup(
                    var.alarms[element(keys(var.alarms), count.index)],
                    "actions",
                    ""
                    )))}"]
}
