module "terraform_backend_admin" {
  source = "./modules/terraform_backend"

  # fixed variables
  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  # set name_suffix if needed
  name_suffix = "admin"

  # add more variables here
  admin_aws_iam_principals = [
    local.aws_caller_identity,
  ]
  readwrite_aws_iam_principals = [
    local.aws_caller_identity,
  ]
  read_aws_iam_principals = [
  ]

  aws_iam_role_github_actions_ci = {
    aws_iam_openid_connect_provider = module.aws_iam_openid_connect_provider_github_actions.aws_iam_openid_connect_provider
    aws_iam_policies = [
      data.aws_iam_policy.aws_managed["ReadOnlyAccess"],
    ]
  }
}
