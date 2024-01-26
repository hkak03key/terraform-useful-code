output "aws_s3_bucket" {
  value = aws_s3_bucket.default
}


output "aws_iam_policies" {
  value = {
    read      = aws_iam_policy.defaults["read"]
    readwrite = aws_iam_policy.defaults["readwrite"]
  }
}
