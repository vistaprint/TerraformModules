resource "aws_iam_role" "iam_for_lambda" {
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
  role   = "${aws_iam_role.iam_for_lambda.id}"
  policy = "${var.policy}"
}

resource "aws_lambda_permission" "lambda_permission" {
  count = "${length(var.functions)}"
  
  statement_id  = "${var.statement_id}"
  action        = "lambda:InvokeFunction"
  function_name = "${element(aws_lambda_function.lambda_function.*.arn, count.index)}"
  principal     = "${var.principal}"
  source_arn    = "${var.source_arn}"
} 

resource "aws_lambda_function" "lambda_function" {
  count = "${length(var.functions)}"

  filename         = "${var.lambda_file}"
  function_name    = "${format("%s%s", var.prefix, element(keys(var.functions), count.index))}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "${lookup(var.functions[element(keys(var.functions), count.index)], "handler")}"
  source_code_hash = "${base64sha256(file("${var.lambda_file}"))}"
  runtime          = "${var.runtime}"
  timeout          = "${var.timeout}"

  environment {
    variables = "${var.variables}"
  }
}
