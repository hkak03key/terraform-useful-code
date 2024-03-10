module "aws_kms" {
  source = "../aws_kms"

  count = (
    var.server_side_encryption["sse_algorithm"] == "aws:kms" && var.server_side_encryption["aws_kms_key"] == null
    ? 1
    : 0
  )

  _system_info              = var._system_info
  _module_hierarchical_info = var._module_hierarchical_info

  name_suffix = "s3"

  admin_aws_iam_principals = local.admin_aws_iam_principals
  user_aws_iam_principals = flatten([
    local.readwrite_aws_iam_principals,
    local.read_aws_iam_principals,
  ])

  enable_access_with_iam_policy  = false
  enable_access_as_user_by_admin = true
}


locals {
  aws_kms_key = (
    var.server_side_encryption["sse_algorithm"] == "aws:kms" && var.server_side_encryption["aws_kms_key"] == null
    ? {
      arn    = module.aws_kms[0].aws_kms_key.arn
      key_id = module.aws_kms[0].aws_kms_key.key_id
    }
    : (
      var.server_side_encryption["sse_algorithm"] == "aws:kms" && var.server_side_encryption["aws_kms_key"] != null
      ? var.server_side_encryption["aws_kms_key"]
      : null
    )
  )
}
