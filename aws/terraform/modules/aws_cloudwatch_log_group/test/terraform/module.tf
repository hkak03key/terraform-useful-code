module "default" {
  source = "../../"

  system_name              = local.system_name
  env                      = var.env
  aws_iam_policy_infos_dir = local.aws_iam_policy_infos_dir
  name_prefix              = local.name_prefix
}
