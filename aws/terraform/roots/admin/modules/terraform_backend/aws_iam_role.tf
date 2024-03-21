module "aws_iam_role_github_actions" {
  for_each = var.aws_iam_role_github_actions_config

  source = "../../../../shared_modules/aws_iam_role_github_actions"

  # fixed variables
  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  # set name_suffix if needed
  name_suffix = each.value["name_suffix"]

  # add more variables here
  aws_iam_openid_connect_provider = each.value["aws_iam_openid_connect_provider"]
  aws_iam_policies                = each.value["aws_iam_policies"]
  github_repository_name          = "hkak03key/terraform-useful-code"
}
