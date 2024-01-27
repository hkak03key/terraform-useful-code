module "defaults" {
  for_each = {
    default = {
    }
    enable_access_with_iam_policy = {
      enable_access_with_iam_policy = true
    }
    enable_access_as_user_by_admin = {
      enable_access_as_user_by_admin = true
    }
  }

  source = "../../"

  system_name              = local.system_name
  env                      = var.env
  aws_iam_policy_infos_dir = local.aws_iam_policy_infos_dir
  name_prefix              = local.name_prefix
  name_suffix              = each.key == "default" ? "" : each.key

  admin_aws_iam_principals = [
    data.aws_caller_identity.default,
    aws_iam_role.defaults["admin_iam_policy_kms_policy"],
    aws_iam_role.defaults["admin_no_iam_policy_kms_policy"],
  ]

  user_aws_iam_principals = [
    data.aws_caller_identity.default,
    # aws_iam_role.defaults["user_iam_policy_kms_policy"],
    aws_iam_role.defaults["user_no_iam_policy_kms_policy"],
  ]

  enable_access_as_user_by_admin = lookup(each.value, "enable_access_as_user_by_admin", null)
  enable_access_with_iam_policy  = lookup(each.value, "enable_access_with_iam_policy", null)
}
