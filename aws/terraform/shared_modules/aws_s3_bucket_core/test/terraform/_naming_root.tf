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
  _module_name_for_test = basename(abspath("${path.module}/../../"))
  module_name           = local._module_name_for_test

  name_prefix = replace(
    join(
      "-",
      compact([
        (
          var.account_name != null
          && var.account_name == try(join("-", compact([var.system_name, var.env])), null) ?
          null :
          var.env
        ),
        var.name_prefix,
        local.append_module_name_to_name_prefix ? local.module_name : "",
      ])
    ), "_", "-"
  )

  long_name_prefix = join(
    "-",
    compact([
      var.account_name != null ? var.account_name : local.aws_account_id,
      local.name_prefix,
    ])
  )
}
