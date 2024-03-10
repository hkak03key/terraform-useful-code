variable "_system_info" {
  type = object({
    env                      = string
    aws_iam_policy_infos_dir = string
    name_prefix              = string
    long_name_prefix         = string
  })
}

variable "_module_hierarchical_info" {
  type = list(
    object({
      module_name                = string
      append_module_name_to_name = bool
      name_suffix                = string
    })
  )
}


variable "name_suffix" {
  type    = string
  default = ""

  description = <<DESC
リソース名に設定されるsuffix。
命名ルールは _naming_module.tf の命名セクションを参照。
DESC
}


variable "cidr_block" {
  type = string
}


variable "subnets" {
  type = list(object({
    subnet_group_name = string
    subnet_mask       = number
    az                = string
  }))
}


variable "nat" {
  type = object({
    az = string # "ALL" or az name ("a", "c", etc...)
  })
}
