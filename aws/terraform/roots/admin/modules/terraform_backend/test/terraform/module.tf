module "default" {
  source = "../../"

  system_name              = local.system_name
  env                      = var.env
  aws_iam_policy_infos_dir = local.aws_iam_policy_infos_dir
  name_prefix              = local.name_prefix

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
