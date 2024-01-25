#======================
# variables
variable "aws_account_name" {
  type    = string
  default = null
}


variable "system_name" {
  type    = string
  default = null
}


variable "env" {
  type    = string
  default = "test"
}


variable "aws_iam_policy_infos_dir" {
  type = string
}


#======================
# validate
resource "null_resource" "check_aws_account_name" {
  triggers = {
    aws_account_name = var.aws_account_name
    system_name      = var.system_name
    env              = var.env
  }

  lifecycle {
    precondition {
      error_message = "var.aws_account_name must be any one of following: \"$${var.system_name}\", \"$${var.system_name}-$${var.env}\" and null."
      condition = (
        var.aws_account_name == null && var.system_name == null
        || (
          var.aws_account_name != null && var.system_name != null
          && (
            var.aws_account_name == var.system_name
            || var.aws_account_name == try("${var.system_name}-${var.env}", null)
          )
        )
      )
    }

    precondition {
      error_message = "var.aws_account_name must set if var.env set."
      condition     = !(var.env != "test" && var.aws_account_name == null)
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
        var.system_name == null
        || can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.env))
      )
    }
  }
}
