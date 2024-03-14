# FIXME module名は aws_iam_role_... のようにterraform resource名で始まるようにする

variable "system_name" {
  type = string
}


variable "env" {
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


variable "aws_iam_openid_connect_provider" {
  type = object({
    arn = string
  })

  validation {
    condition     = try(regex("^arn:aws:iam::[0-9]{12}:oidc-provider/", var.aws_iam_openid_connect_provider.arn), null) != null
    error_message = "The arn of aws_iam_openid_connect_provider must be a arn of IAM OIDC Provider."
  }
}


variable "github_repository_name" {
  type = string

  description = <<DESC
本moduleで作成されるIAM Roleにアクセスできるgithub repository名。
"{organization}/{repo}" で指定する。
DESC

  validation {
    condition     = try(regex("^[a-zA-Z0-9-_.]+/[a-zA-Z0-9-_.*]+$", var.github_repository_name), null) != null
    error_message = "The value of github_repository_name must be \"{organization}/{repo}\"."
  }
}


variable "aws_iam_policies" {
  type = list(object({
    name = string
    arn  = string
  }))

  validation {
    condition = alltrue([
      for p in var.aws_iam_policies :
      try(regex("^arn:aws:iam::([0-9]{12}|aws):policy", p.arn), null) != null
    ])
    error_message = "The arn of element of aws_iam_policies must be a arn of IAM Policy."
  }
}
