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


variable "ingress_aws_security_groups" {
  type = list(any)

  default = []

  validation {
    error_message = "The element of ingress_aws_security_groups must be a aws_security_group resource."
    condition = alltrue([
      for sg in var.ingress_aws_security_groups :
      try(regex("^arn:aws:ec2:.*:security-group/.*", sg.arn), null) != null
    ])
  }

  validation {
    error_message = "The element of ingress_aws_security_groups must have tags[\"Name\"] attribute."
    condition = alltrue([
      for sg in var.ingress_aws_security_groups :
      try(sg.tags["Name"], null) != null
    ])
  }

  validation {
    error_message = "The element of ingress_aws_security_groups must be craeted by aws_security_group_connector module."
    condition = alltrue([
      for sg in var.ingress_aws_security_groups :
      try(sg.tags["aws_security_group_connector"], null) == "true"
    ])
  }
}


variable "egress_aws_security_groups" {
  type = list(any)

  default = []

  validation {
    error_message = "The element of egress_aws_security_groups must be a aws_security_group."
    condition = alltrue([
      for sg in var.egress_aws_security_groups :
      try(regex("^arn:aws:ec2:.*:security-group/.*", sg.arn), null) != null
    ])
  }

  validation {
    error_message = "The element of egress_aws_security_groups must have tags[\"Name\"] attribute."
    condition = alltrue([
      for sg in var.egress_aws_security_groups :
      try(sg.tags["Name"], null) != null
    ])
  }

  validation {
    error_message = "The element of egress_aws_security_groups must be craeted by aws_security_group_connector module."
    condition = alltrue([
      for sg in var.egress_aws_security_groups :
      try(sg.tags["aws_security_group_connector"], null) == "true"
    ])
  }
}
