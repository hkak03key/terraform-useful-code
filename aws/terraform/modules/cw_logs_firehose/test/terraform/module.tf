module "default" {
  source = "../../"

  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info
}
