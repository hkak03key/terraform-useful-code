#======================
# variables
variable "account_name" {
  type    = string
  default = null
}


variable "system_name" {
  type    = string
  default = null
}


variable "env" {
  type    = string
  default = null
}


variable "name_prefix" {
  type    = string
  default = null
}


variable "aws_iam_policy_infos_dir" {
  type = string
}


#======================
# validate
resource "null_resource" "check_account_name" {
  triggers = {
    account_name = var.account_name
    system_name  = var.system_name
    env          = var.env
  }

  lifecycle {
    precondition {
      error_message = "var.account_name must be any one of following: \"$${var.system_name}\", \"$${var.system_name}-$${var.env}\" and null."
      condition = (
        var.account_name == null && var.system_name == null
        || (
          var.account_name != null && var.system_name != null
          && (
            var.account_name == var.system_name
            || var.account_name == try(join("-", compact([var.system_name, var.env])), null)
          )
        )
      )
    }

    precondition {
      error_message = "var.account_name must set if var.env set."
      condition     = !(var.env != null && var.account_name == null)
    }
  }
}


resource "null_resource" "check_system_name" {
  triggers = {
    system_name = var.system_name
  }

  lifecycle {
    precondition {
      error_message = "var.system_name must match with \"^[a-z0-9][a-z0-9-]*[a-z0-9]$\" or null."
      condition = (
        var.system_name == null
        || can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.system_name))
      )
    }
  }
}


resource "null_resource" "check_env" {
  triggers = {
    env = var.env
  }

  lifecycle {
    precondition {
      error_message = "var.env must match with \"^[a-z0-9][a-z0-9-]*[a-z0-9]$\" or null."
      condition = (
        var.env == null
        || can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.env))
      )
    }
  }
}
