module "aws_s3_bucket_secure" {
  source = "../../../../shared_modules/aws_s3_bucket_secure"

  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  admin_aws_iam_principals     = var.admin_aws_iam_principals
  readwrite_aws_iam_principals = var.readwrite_aws_iam_principals
  read_aws_iam_principals = flatten([
    var.read_aws_iam_principals,
    values(module.aws_iam_role_github_actions)[*].aws_iam_role,
  ])

  server_side_encryption = {
    sse_algorithm = "aws:kms"
    aws_kms_key   = null
  }

  use_bucket_policy_for_access_control = true
}
