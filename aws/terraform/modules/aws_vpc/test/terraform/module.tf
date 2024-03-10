module "default" {
  source = "../../"

  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

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

  nat = {
    az = "ALL"
  }
}
