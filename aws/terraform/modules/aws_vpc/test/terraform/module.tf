module "default" {
  source = "../../"

  system_name              = local.system_name
  env                      = var.env
  aws_iam_policy_infos_dir = local.aws_iam_policy_infos_dir
  name_prefix              = local.name_prefix

  cidr_block = "10.0.0.0/16"

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
