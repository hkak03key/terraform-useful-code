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
    ])
    error_message = "The arn of element of admin_aws_iam_principals must be a arn of IAM User or Role."
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
    ])
    error_message = "The arn of element of readwrite_aws_iam_principals must be a arn of IAM User or Role."
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
    ])
    error_message = "The arn of element of read_aws_iam_principals must be a arn of IAM User or Role."
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
