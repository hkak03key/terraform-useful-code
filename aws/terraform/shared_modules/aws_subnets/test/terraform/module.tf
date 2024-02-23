module "default" {
  source = "../../"

  system_name              = local.system_name
  env                      = var.env
  aws_iam_policy_infos_dir = local.aws_iam_policy_infos_dir
  name_prefix              = local.name_prefix

  aws_vpc = aws_vpc.default

  available_cidr_block = aws_vpc.default.cidr_block

  subnet_groups = [
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
  subnets = [
    {
      subnet_group_name = "front"
      subnet_mask       = 27
      az                = "a"
    },
    {
      subnet_group_name = "front"
      subnet_mask       = 27
      az                = "c"
    },
    {
      subnet_group_name = "app"
      subnet_mask       = 27
      az                = "a"
    },
    {
      subnet_group_name = "app"
      subnet_mask       = 27
      az                = "c"
    },
    {
      subnet_group_name = "internal"
      subnet_mask       = 27
      az                = "a"
    },
    {
      subnet_group_name = "internal"
      subnet_mask       = 27
      az                = "c"
    },
  ]
}
