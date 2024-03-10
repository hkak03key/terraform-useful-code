/************************
# Bucket
************************/
resource "aws_s3_bucket" "default" {
  bucket = local.long_name_prefix
}


/************************
# IAM Policy
************************/
resource "aws_iam_policy" "defaults" {
  for_each = local._aws_iam_policy_aws_s3_bucket_defaults

  name        = each.value["name"]
  path        = "/"
  description = ""

  policy = jsonencode(each.value["policy"])
}


locals {
  _aws_iam_policy_aws_s3_bucket_defaults = {
    for v in [
      "read",
      "readwrite",
    ] :
    v => jsondecode(
      templatefile(
        "${var._system_info["aws_iam_policy_infos_dir"]}/s3_${v}.json.tftpl",
        {
          aws_s3_bucket_name = aws_s3_bucket.default.bucket
        }
      )
    )
  }
}
