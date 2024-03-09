locals {
  _module_hierarchical_info = concat(
    var._module_hierarchical_info,
    [
      {
        module_name                = local.module_name
        append_module_name_to_name = local.append_module_name_to_name_prefix
        name_suffix                = var.name_suffix
      }
    ]
  )
}
