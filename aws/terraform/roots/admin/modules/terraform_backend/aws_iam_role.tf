module "aws_iam_role_github_actions_ci" {
  source = "../../../../shared_modules/aws_iam_role_github_actions"

  # fixed variables
  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  # set name_suffix if needed
  name_suffix = "ci"

  # add more variables here
  aws_iam_openid_connect_provider = var.aws_iam_role_github_actions_ci["aws_iam_openid_connect_provider"]
  aws_iam_policies                = var.aws_iam_role_github_actions_ci["aws_iam_policies"]
  github_repository_name          = "hkak03key/terraform-useful-code"
}
