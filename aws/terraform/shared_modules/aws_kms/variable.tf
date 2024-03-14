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


variable "admin_aws_iam_principals" {
  type = list(object(
    {
      arn = string
    }
  ))

  validation {
    condition     = length(var.admin_aws_iam_principals) > 0
    error_message = "The admin_aws_iam_principals value length must be > 0."
  }

  validation {
    condition = alltrue([
      for p in var.admin_aws_iam_principals :
      try(regex("^arn:aws:iam::[0-9]{12}:(user|role)", p.arn), null) != null
    ])
    error_message = <<MSG
The arn of element of admin_aws_iam_principals must be a arn of IAM User or Role.
(provided value: ${jsonencode(var.admin_aws_iam_principals[*].arn)})
MSG
  }

  description = <<DESC
KMSを管理するIAM Principalリソースのリスト。
ここで、IAM Principalリソースは、 aws_iam_user のようにarnを保持するobjectを指す。
また、受け付けるIAM PrincipalはIAM User / Role のいずれかである。

このmoduleを利用してdeployを行うIAM Princpalは、このリストに含まれる必要がある。
DESC
}


variable "user_aws_iam_principals" {
  type = list(object(
    {
      arn = string
    }
  ))

  validation {
    condition = alltrue([
      for p in var.user_aws_iam_principals :
      try(regex("^arn:aws:iam::[0-9]{12}:(root|user|role)", p.arn), null) != null
    ])
    error_message = <<MSG
The arn of element of user_aws_iam_principals must be a arn of IAM Root, User or Role.
(provided value: ${jsonencode(var.user_aws_iam_principals[*].arn)})
MSG
  }

  description = <<DESC
KMSを利用するIAM Principalリソースのリスト。
ここで、IAM Principalリソースは、 aws_iam_user のようにarnを保持するobjectを指す。
また、受け付けるIAM PrincipalはIAM Root / User / Role のいずれかである。
DESC
}


variable "additional_kms_policy" {
  type    = string
  default = null

  description = <<DESC
defaultで生成されるKMS Policyに追加するKMS Policy。
DESC

  validation {
    condition = (
      var.additional_kms_policy != null ?
      alltrue([
        for v in keys(jsondecode(var.additional_kms_policy)) :
        contains(["Version", "Id", "Statement"], v)
      ]) :
      true
    )
    error_message = "The additional_kms_policy must be a valid policy."
  }
}


variable "enable_access_with_iam_policy" {
  type     = bool
  default  = false
  nullable = false

  description = <<DESC
IAM PolicyがKMSへのアクセスを許可できるようにするか否か。
詳細はドキュメントを参照。
https://docs.aws.amazon.com/ja_jp/kms/latest/developerguide/key-policy-default.html
DESC
}


variable "enable_read_access_with_iam_policy" {
  type     = bool
  default  = true
  nullable = false

  description = <<DESC
IAM PolicyがKMSへの読み込みアクセスを許可できるようにするか否か。
DESC
}


variable "enable_access_as_user_by_admin" {
  type     = bool
  default  = false
  nullable = false

  description = <<DESC
admin_aws_iam_principals に指定されたIAM Principalが、KMS Keyを利用できるようにするか否か。
DESC
}
