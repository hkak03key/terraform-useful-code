module "aws_subnets" {
  source = "../../shared_modules/aws_subnets"

  _system_info              = var._system_info
  _module_hierarchical_info = var._module_hierarchical_info

  aws_vpc = aws_vpc.default

  available_cidr_block = aws_vpc.default.cidr_block

  subnet_groups = [
    {
      name                    = "firewall"
      map_public_ip_on_launch = true
    },
    {
      name                    = "front"
      map_public_ip_on_launch = true
    },
    {
      name                    = "app"
      map_public_ip_on_launch = false
    },
    {
      name                    = "internal"
      map_public_ip_on_launch = false
    },
  ]
  subnets = var.subnets
}


locals {
  aws_subnets_flattened_each_groups = {
    for group in keys(module.aws_subnets.aws_subnets) :
    group => flatten([
      for az in keys(module.aws_subnets.aws_subnets[group]) :
      [
        for index in range(length(module.aws_subnets.aws_subnets[group][az])) :
        {
          az         = az
          index      = index
          aws_subnet = module.aws_subnets.aws_subnets[group][az][index]
        }
      ]
    ])
  }
}
