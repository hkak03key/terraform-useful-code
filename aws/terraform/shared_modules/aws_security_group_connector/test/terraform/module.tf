module "ingress" {
  source = "../../"

  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  aws_vpc = aws_vpc.default

  ingress_aws_security_groups = [
    module.egress.aws_security_group,
  ]
}


module "egress" {
  source = "../../"

  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  aws_vpc = aws_vpc.default

  egress_aws_security_groups = [
    module.ingress.aws_security_group,
  ]
}
