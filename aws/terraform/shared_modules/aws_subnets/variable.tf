variable "system_name" {
  type = string
}


variable "env" {
  type = string
}


variable "aws_iam_policy_infos_dir" {
  type = string
}


variable "name_prefix" {
  type = string

  description = <<DESC
リソース名に設定されるprefix。
命名ルールは locals.tf の命名セクションを参照。
DESC
}


variable "name_suffix" {
  type    = string
  default = ""

  description = <<DESC
リソース名に設定されるsuffix。
命名ルールは locals.tf の命名セクションを参照。
DESC
}


variable "aws_vpc" {
  type = object({
    id = string
  })
}

variable "available_cidr_block" {
  type = string
}


variable "subnet_configures" {
  type = list(object({
    subnet_group_name       = string
    subnet_mask             = number
    az                      = string
    map_public_ip_on_launch = bool
  }))
}
