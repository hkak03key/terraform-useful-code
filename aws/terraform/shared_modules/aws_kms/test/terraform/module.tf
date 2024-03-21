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

  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  name_suffix = each.key == "default" ? "" : each.key

  admin_aws_iam_principals = [
    local.aws_caller_identity,
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
