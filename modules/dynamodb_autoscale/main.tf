locals {

  autoscale_default = {
      enabled = false
      target_value       = 70
      min_capacity       = 1
      max_capacity       = 1
  }

  read_autoscale = "${merge(local.autoscale_default, var.read_autoscale)}"
  write_autoscale = "${merge(local.autoscale_default, var.write_autoscale)}"
}

resource "aws_iam_role" "dynamodb_autoscale_role" {
  name = "${var.table_name}_autoscale_role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "autoscaling_role_policy" {
  name = "${var.table_name}_autoscaling_role_policy"
  role = "${aws_iam_role.dynamodb_autoscale_role.name}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:DescribeTable",
                "dynamodb:UpdateTable",
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DeleteAlarms"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# DynamoDb read autoscaling policy
resource "aws_appautoscaling_target" "read_autoscaling_target" {
  count              = "${local.read_autoscale["enabled"] ? 1 : 0}"
  service_namespace  = "dynamodb"
  resource_id        = "table/${var.table_name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  role_arn           = "${aws_iam_role.dynamodb_autoscale_role.arn}"
  min_capacity       = "${local.read_autoscale["min_capacity"]}"
  max_capacity       = "${local.read_autoscale["max_capacity"]}"
  depends_on         = ["aws_iam_role_policy.autoscaling_role_policy"]

   lifecycle {
    ignore_changes = [
      "role_arn",
      "id"
    ]
  }
}

resource "aws_appautoscaling_policy" "read_autoscaling_policy" {
  count              = "${local.read_autoscale["enabled"] ? 1 : 0}"
  name               = "${var.table_name}_read_autoscaling_policy"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = "${aws_appautoscaling_target.read_autoscaling_target.service_namespace}"
  resource_id        = "${aws_appautoscaling_target.read_autoscaling_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.read_autoscaling_target.scalable_dimension}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value       = "${local.read_autoscale["target_value"]}"
  }

  # broken: will get fixed with https://github.com/terraform-providers/terraform-provider-aws/issues/538
  depends_on         = ["aws_appautoscaling_target.read_autoscaling_target"]
}

# DynamoDb write autoscaling policy
resource "aws_appautoscaling_target" "write_autoscaling_target" {
  count              = "${local.write_autoscale["enabled"] ? 1 : 0}"

  service_namespace  = "dynamodb"
  resource_id        = "table/${var.table_name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  role_arn           = "${aws_iam_role.dynamodb_autoscale_role.arn}"
  min_capacity       = "${local.write_autoscale["min_capacity"]}"
  max_capacity       = "${local.write_autoscale["max_capacity"]}"
  depends_on         = ["aws_iam_role_policy.autoscaling_role_policy"]
}

resource "aws_appautoscaling_policy" "write_autoscaling_policy" {
  count              = "${local.write_autoscale["enabled"] ? 1 : 0}"

  name               = "${var.table_name}_write_autoscaling_policy"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = "${aws_appautoscaling_target.write_autoscaling_target.service_namespace}"
  resource_id        = "${aws_appautoscaling_target.write_autoscaling_target.id}"
  scalable_dimension = "${aws_appautoscaling_target.write_autoscaling_target.scalable_dimension}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    
  target_value       = "${local.write_autoscale["target_value"]}"
  }

  # broken: will get fixed with https://github.com/terraform-providers/terraform-provider-aws/issues/538
  depends_on         = ["aws_appautoscaling_target.write_autoscaling_target"]
}