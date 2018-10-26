resource "aws_iam_role" "iam_for_lambda" {
  count = "${var.create_role ? 1 : 0}"

  name = "${var.prefix}iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "policy_for_lambda" {
  count  = "${var.policy == "" ? 0 : 1}"
  name   = "${var.prefix}policy_for_lambda"
  role   = "${var.create_role ? join("", aws_iam_role.iam_for_lambda.*.arn) : var.role_arn}"
  policy = "${var.policy}"
}

resource "aws_lambda_permission" "lambda_permission" {
  count = "${length(var.functions) * var.permission_count}"

  action        = "lambda:InvokeFunction"
  function_name = "${element(aws_lambda_function.lambda_function.*.arn, count.index / var.permission_count)}"
  principal     = "${lookup(var.permissions[count.index % var.permission_count], "principal")}"
  statement_id  = "${lookup(var.permissions[count.index % var.permission_count], "statement_id")}"
  source_arn    = "${lookup(var.permissions[count.index % var.permission_count], "source_arn")}"
}

resource "aws_lambda_function" "lambda_function" {
  count = "${length(var.functions)}"

  filename         = "${var.lambda_file}"
  function_name    = "${format("%s%s", var.prefix, element(keys(var.functions), count.index))}"
  role             = "${var.create_role ? join("", aws_iam_role.iam_for_lambda.*.arn) : var.role_arn}"
  handler          = "${lookup(var.functions[element(keys(var.functions), count.index)], "handler")}"
  source_code_hash = "${base64sha256(file("${var.lambda_file}"))}"
  runtime          = "${var.runtime}"
  timeout          = "${var.timeout}"
  tags             = "${var.tags}"
  memory_size      = "${var.memory_size}"

  environment {
    variables = "${var.env_vars}"
  }
}
