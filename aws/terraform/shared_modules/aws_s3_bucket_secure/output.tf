output "aws_s3_bucket" {
  value = module.aws_s3_bucket_core.aws_s3_bucket
}


/*
本moduleに限り、内部でiam policyをattachする
output "aws_iam_policies" {
}
*/


output "aws_kms_key" {
  value = (
    var.server_side_encryption["sse_algorithm"] == "aws:kms" && var.server_side_encryption["aws_kms_key"] == null
    ? module.aws_kms[0].aws_kms_key
    : null
  )
}


output "aws_kms_alias" {
  value = (
    var.server_side_encryption["sse_algorithm"] == "aws:kms" && var.server_side_encryption["aws_kms_key"] == null
    ? module.aws_kms[0].aws_kms_alias
    : null
  )
}
