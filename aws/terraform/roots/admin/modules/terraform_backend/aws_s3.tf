module "aws_s3_bucket_secure" {
  source = "../../../../shared_modules/aws_s3_bucket_secure"

  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  name_suffix = random_password.aws_s3_bucket_secure_suffix.result

  admin_aws_iam_principals     = var.admin_aws_iam_principals
  readwrite_aws_iam_principals = var.readwrite_aws_iam_principals
  read_aws_iam_principals      = var.read_aws_iam_principals

  server_side_encryption = {
    sse_algorithm = "aws:kms"
    aws_kms_key   = null
  }

  use_bucket_policy_for_access_control = true
}


resource "random_password" "aws_s3_bucket_secure_suffix" {
  length  = 6
  lower   = true
  upper   = false
  special = false
}
