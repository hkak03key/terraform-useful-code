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


variable "aws_vpc" {
  type = object({
    id = string
  })
}

variable "available_cidr_block" {
  type = string
}


variable "subnet_groups" {
  type = list(object({
    name                    = string
    map_public_ip_on_launch = bool
  }))

  validation {
    error_message = "var.subnet_groups[*].name must be unique."
    condition     = length(var.subnet_groups) == length(distinct(var.subnet_groups[*].name))
  }
}


variable "subnets" {
  type = list(object({
    subnet_group_name = string
    subnet_mask       = number
    az                = string
  }))
}


#======================
# validate
resource "null_resource" "check_subnet_groups_and_subnets" {
  triggers = {
    subnet_groups = jsonencode(var.subnet_groups)
    subnets       = jsonencode(var.subnets)
  }

  lifecycle {
    precondition {
      condition = alltrue([
        for subnet in var.subnets : contains(var.subnet_groups[*].name, subnet.subnet_group_name)
      ])
      error_message = "each subnet_group_name of var.subnets must be one of var.subnet_groups[*].name: ${jsonencode(var.subnet_groups[*].name)}."
    }
  }
}
