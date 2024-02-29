output "aws_lambda_function" {
  value = aws_lambda_function.default
}


output "aws_iam_policy" {
  value = aws_iam_policy.lambda_exec
}
