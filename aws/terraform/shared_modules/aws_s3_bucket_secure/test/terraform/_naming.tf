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
  # _module_name = basename(abspath("${path.module}/../../"))
  _module_name = "s3_secure"

  system_name = (
    var.system_name != null ?
    var.system_name :
    local.aws_account_id
  )

  name_prefix = replace(
    join(
      "-",
      compact([
        var.name_prefix,
        local.append_module_name_to_name_prefix ? local._module_name : "",
      ])
    ), "_", "-"
  )
  long_name_prefix = join("-", compact([local.system_name, var.env, local.name_prefix]))
}
