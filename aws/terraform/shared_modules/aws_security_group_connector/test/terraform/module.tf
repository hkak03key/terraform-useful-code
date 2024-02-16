module "ingress" {
  source = "../../"

  system_name              = local.system_name
  env                      = var.env
  aws_iam_policy_infos_dir = local.aws_iam_policy_infos_dir
  name_prefix              = local.name_prefix

  aws_vpc = aws_vpc.default

  ingress_aws_security_groups = [
    module.egress.aws_security_group,
  ]
}


module "egress" {
  source = "../../"

  system_name              = local.system_name
  env                      = var.env
  aws_iam_policy_infos_dir = local.aws_iam_policy_infos_dir
  name_prefix              = local.name_prefix

  aws_vpc = aws_vpc.default

  egress_aws_security_groups = [
    module.ingress.aws_security_group,
  ]
}
