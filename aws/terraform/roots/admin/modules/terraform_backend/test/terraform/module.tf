module "default" {
  source = "../../"

  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  admin_aws_iam_principals = [
    local.aws_caller_identity,
  ]
  readwrite_aws_iam_principals = [
    aws_iam_role.defaults["readwrite"],
  ]
  read_aws_iam_principals = [
    aws_iam_role.defaults["read"],
  ]
}
