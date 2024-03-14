module "aws_iam_openid_connect_provider_github_actions" {
  source = "./modules/aws_iam_openid_connect_provider_github_actions"

  # fixed variables
  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info
}
