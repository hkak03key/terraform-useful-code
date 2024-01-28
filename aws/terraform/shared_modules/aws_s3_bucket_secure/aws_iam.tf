resource "aws_iam_policy_attachment" "aws_s3_bucket_core_readwrite" {
  count = length(local.readwrite_aws_iam_principals) > 0 ? 1 : 0

  name = "${module.aws_s3_bucket_core.aws_s3_bucket.id}-readwrite"
  roles = [
    for p in local.readwrite_aws_iam_principals :
    p.name if try(regex("^arn:aws:iam::[0-9]{12}:role", p.arn), null) != null
  ]
  users = [
    for p in local.readwrite_aws_iam_principals :
    p.name if try(regex("^arn:aws:iam::[0-9]{12}:user", p.arn), null) != null
  ]
  policy_arn = module.aws_s3_bucket_core.aws_iam_policies["readwrite"].arn
}


resource "aws_iam_policy_attachment" "aws_s3_bucket_core_read" {
  count = length(local.read_aws_iam_principals) > 0 ? 1 : 0

  name = "${module.aws_s3_bucket_core.aws_s3_bucket.id}-read"
  roles = [
    for p in local.read_aws_iam_principals :
    p.name if try(regex("^arn:aws:iam::[0-9]{12}:role", p.arn), null) != null
  ]
  users = [
    for p in local.read_aws_iam_principals :
    p.name if try(regex("^arn:aws:iam::[0-9]{12}:user", p.arn), null) != null
  ]
  policy_arn = module.aws_s3_bucket_core.aws_iam_policies["read"].arn
}
