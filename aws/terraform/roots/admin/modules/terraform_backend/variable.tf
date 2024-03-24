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
命名ルールは locals.tf の命名セクションを参照。
DESC
}


variable "admin_aws_iam_principals" {
  type = list(object(
    {
      arn       = string
      name      = string
      unique_id = optional(string, null)
      user_id   = optional(string, null)
    }
  ))

  validation {
    condition = alltrue([
      for p in var.admin_aws_iam_principals :
      try(regex("^arn:aws:iam::[0-9]{12}:(user|role)", p.arn), null) != null
      || try(regex("^arn:aws:sts::[0-9]{12}:assumed-role/", p.arn), null) != null
    ])
    error_message = <<MSG
The arn of element of admin_aws_iam_principals must be a arn of IAM User or Role.
(provided value: ${jsonencode(var.admin_aws_iam_principals[*].arn)})
MSG
  }

  validation {
    condition = alltrue([
      for p in var.admin_aws_iam_principals :
      (
        p.unique_id == null && p.user_id != null
        || p.unique_id != null && p.user_id == null
      )
    ])
    error_message = "Either unique_id or user_id must be specified."
  }
}


variable "readwrite_aws_iam_principals" {
  type = list(object(
    {
      arn       = string
      name      = string
      unique_id = optional(string, null)
      user_id   = optional(string, null)
    }
  ))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for p in var.readwrite_aws_iam_principals :
      try(regex("^arn:aws:iam::[0-9]{12}:(user|role)", p.arn), null) != null
      || try(regex("^arn:aws:sts::[0-9]{12}:assumed-role/", p.arn), null) != null
    ])
    error_message = <<MSG
The arn of element of readwrite_aws_iam_principals must be a arn of IAM User or Role.
(provided value: ${jsonencode(var.readwrite_aws_iam_principals[*].arn)})
MSG
  }

  validation {
    condition = alltrue([
      for p in var.readwrite_aws_iam_principals :
      (
        p.unique_id == null && p.user_id != null
        || p.unique_id != null && p.user_id == null
      )
    ])
    error_message = "Either unique_id or user_id must be specified."
  }
}


variable "read_aws_iam_principals" {
  type = list(object(
    {
      arn       = string
      name      = string
      unique_id = optional(string, null)
      user_id   = optional(string, null)
    }
  ))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for p in var.read_aws_iam_principals :
      try(regex("^arn:aws:iam::[0-9]{12}:(user|role)", p.arn), null) != null
      || try(regex("^arn:aws:sts::[0-9]{12}:assumed-role/", p.arn), null) != null
    ])
    error_message = <<MSG
The arn of element of read_aws_iam_principals must be a arn of IAM User or Role.
(provided value: ${jsonencode(var.read_aws_iam_principals[*].arn)})
MSG
  }

  validation {
    condition = alltrue([
      for p in var.read_aws_iam_principals :
      (
        p.unique_id == null && p.user_id != null
        || p.unique_id != null && p.user_id == null
      )
    ])
    error_message = "Either unique_id or user_id must be specified."
  }
}


variable "aws_iam_role_github_actions_config" {
  type = map(
    object({
      name_suffix                     = optional(string, null)
      aws_iam_openid_connect_provider = any
      aws_iam_policies = list(object({
        id   = string
        name = string
        arn  = string
      }))
      is_output = bool
    })
  )
  default = {}
}
