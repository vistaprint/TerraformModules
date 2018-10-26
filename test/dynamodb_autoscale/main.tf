provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

locals {
  table_info = [
    {
      name           = "${var.prefix}Table1"
      read_capacity  = 1
      write_capacity = 1
    },
    {
      name           = "${var.prefix}Table2"
      read_capacity  = 1
      write_capacity = 1
    },
    {
      name           = "${var.prefix}Table3"
      read_capacity  = 1
      write_capacity = 1
    },
  ]
}

module "table" {
  source     = "vistaprint/dynamodb-tables/aws"
  version    = "0.0.1"
  table_info = "${local.table_info}"
}

resource "aws_iam_role" "common_dynamodb_autoscale_role" {
  name = "${var.prefix}_common_autoscale_role"

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

resource "aws_iam_role_policy" "common_autoscaling_role_policy" {
  name = "${var.prefix}_common_autoscaling_role_policy"
  role = "${aws_iam_role.common_dynamodb_autoscale_role.name}"

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

module "autoscale_with_provided_role_1" {
  source = "../../modules/dynamodb_autoscale"

  table_name = "${element(module.table.names, 0)}"

  create_role = false
  role_arn = "${aws_iam_role.common_dynamodb_autoscale_role.arn}"
  policy_id = "${aws_iam_role_policy.common_autoscaling_role_policy.id}"

  read_autoscale = {
    enabled = true

    # if min/max capacity is changed, target_value has to also be changed due to dependency not working
    # broken: will get fixed with https://github.com/terraform-providers/terraform-provider-aws/issues/538
    target_value = 75

    min_capacity = "${lookup(local.table_info[0], "read_capacity")}"
    max_capacity = 10
  }
}

module "autoscale_with_provided_role_2" {
  source = "../../modules/dynamodb_autoscale"

  table_name = "${element(module.table.names, 1)}"

  create_role = false
  role_arn = "${aws_iam_role.common_dynamodb_autoscale_role.arn}"
  policy_id = "${aws_iam_role_policy.common_autoscaling_role_policy.id}"

  read_autoscale = {
    enabled = true

    # if min/max capacity is changed, target_value has to also be changed due to dependency not working
    # broken: will get fixed with https://github.com/terraform-providers/terraform-provider-aws/issues/538
    target_value = 50

    min_capacity = "${lookup(local.table_info[1], "read_capacity")}"
    max_capacity = 8
  }
}

module "autoscale" {
  source = "../../modules/dynamodb_autoscale"

  table_name = "${element(module.table.names, 2)}"

  read_autoscale = {
    enabled = true

    # if min/max capacity is changed, target_value has to also be changed due to dependency not working
    # broken: will get fixed with https://github.com/terraform-providers/terraform-provider-aws/issues/538
    target_value = 70

    min_capacity = "${lookup(local.table_info[2], "read_capacity")}"
    max_capacity = 20
  }
}
