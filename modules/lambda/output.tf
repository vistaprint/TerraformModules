output "lambda_arns" {
  value = zipmap(keys(var.functions), aws_lambda_function.lambda_function.*.arn)
}

output "lambda_names" {
  value = zipmap(keys(var.functions), aws_lambda_function.lambda_function.*.function_name)
}
