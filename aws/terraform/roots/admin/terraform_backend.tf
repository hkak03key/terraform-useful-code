module "terraform_backend_admin" {
  source = "./modules/terraform_backend"

  # fixed variables
  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  # set name_suffix if needed
  name_suffix = "admin"

  # add more variables here
  admin_aws_iam_principals     = local.admin_aws_iam_principals
  readwrite_aws_iam_principals = local.admin_aws_iam_principals

  read_aws_iam_principals = [
  ]

  aws_iam_role_github_actions_config = {
    ci = {
      name_suffix                     = "ci"
      aws_iam_openid_connect_provider = module.aws_iam_openid_connect_provider_github_actions.aws_iam_openid_connect_provider
      aws_iam_policies = [
        data.aws_iam_policy.aws_managed["ReadOnlyAccess"],
      ]
      is_output = true
    }
    deploy = {
      name_suffix                     = "deploy"
      aws_iam_openid_connect_provider = module.aws_iam_openid_connect_provider_github_actions.aws_iam_openid_connect_provider
      aws_iam_policies = [
        data.aws_iam_policy.aws_managed["AdministratorAccess"],
      ]
      is_output = true
    }
  }
}


module "terraform_backend_ci_tf_module" {
  source = "./modules/terraform_backend"

  # fixed variables
  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  # set name_suffix if needed
  name_suffix = "ci_tf_module"

  # add more variables here
  admin_aws_iam_principals = local.admin_aws_iam_principals
  readwrite_aws_iam_principals = flatten([
    local.admin_aws_iam_principals,
    module.terraform_backend_ci_tf_module.aws_iam_role_github_actions["default"].aws_iam_role,
  ])

  read_aws_iam_principals = flatten([
    module.terraform_backend_admin.aws_iam_role_github_actions["ci"].aws_iam_role,
  ])

  aws_iam_role_github_actions_config = {
    default = {
      name_suffix                     = null
      aws_iam_openid_connect_provider = module.aws_iam_openid_connect_provider_github_actions.aws_iam_openid_connect_provider
      aws_iam_policies = [
        data.aws_iam_policy.aws_managed["ReadOnlyAccess"],
        aws_iam_policy.administrator_access_for_ci_tf_module,
      ]
      is_output = true
    }
  }
}
