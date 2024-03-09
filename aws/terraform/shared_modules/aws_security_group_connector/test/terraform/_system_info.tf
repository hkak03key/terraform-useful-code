locals {
  _system_info = {
    env                      = var.env
    aws_iam_policy_infos_dir = local.aws_iam_policy_infos_dir
    name_prefix              = local.name_prefix
    long_name_prefix         = local.long_name_prefix
  }
}
