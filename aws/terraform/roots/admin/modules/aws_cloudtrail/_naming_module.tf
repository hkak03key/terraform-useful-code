locals {
  #======================
  # 命名
  #----------------------
  # フラグ
  /* append_module_name_to_name_prefix
  true の場合、 local.name_prefix は "${var.name_prefix}-${moduleのディレクトリ名}[-${var.name_suffix}]" となる
  false の場合、 local.name_prefix は "${var.name_prefix}[-${var.name_suffix}]" となる
  */
  append_module_name_to_name_prefix = true

  #----------------------
  # 変数
  # defaultではmoduleのディレクトリ名が入るが、任意に変更可能
  _module_default_name = basename(abspath(path.module))
  module_name          = "cloudtrail"

  name_prefix = replace(
    join(
      "-",
      compact(flatten([
        [var._system_info["name_prefix"]],
        [
          for h in local._module_hierarchical_info : (
            h.append_module_name_to_name ?
            [h.module_name, h.name_suffix] :
            [h.name_suffix]
          )
        ],
      ]))
    ), "_", "-"
  )

  long_name_prefix = replace(
    join(
      "-",
      compact(flatten([
        [var._system_info["long_name_prefix"]],
        [
          for h in local._module_hierarchical_info : (
            h.append_module_name_to_name ?
            [h.module_name, h.name_suffix] :
            [h.name_suffix]
          )
        ],
      ]))
    ), "_", "-"
  )
}
