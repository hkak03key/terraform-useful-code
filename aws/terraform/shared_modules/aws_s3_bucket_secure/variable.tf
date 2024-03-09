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


variable "server_side_encryption" {
  type = object({
    sse_algorithm = string
    aws_kms_key = optional(object({
      arn    = string
      key_id = string
    }), null)
  })

  description = <<DESC
S3 Bucket上に作成するObjectの暗号化に利用するServer Side Encryptionの設定を行う。
sse_algorithmには、以下のいずれかを指定する:
- AES256
- aws:kms

"aws:kms" を指定した場合、S3の書き込みにおいてKMSの利用を強制するBucket Policyが設定される。

`aws_kms_key` は、module外で作成されたKMSを利用する場合に指定する。
指定しない場合、module内で作成されるKMSが利用される。
module内で作成されるKMSは、以下のようなKMS Policyが設定される:
- `admin_aws_iam_principals` で指定したprincipalには、KMSのすべての権限を付与する。
- `readwrite_aws_iam_principals` `read_aws_iam_principals` で指定したprincipalには、KMSへの利用権限を付与する。即ち、暗号化/復号化に関する権限が与えられる。
DESC

  validation {
    condition     = var.server_side_encryption.sse_algorithm == "AES256" || var.server_side_encryption.sse_algorithm == "aws:kms"
    error_message = "sse_algorithm must be AES256 or aws:kms."
  }

  validation {
    condition     = !(var.server_side_encryption.sse_algorithm == "AES256" && var.server_side_encryption.aws_kms_key != null)
    error_message = "aws_kms_key must be null when sse_algorithm is AES256."
  }
}


variable "use_bucket_policy_for_access_control" {
  type = bool

  description = <<DESC
S3 Bucketへのアクセス制御にBucket Policyを利用する。
trueにした場合、以下の通りとなる:
- S3へのアクセス許可は、variable `admin_aws_iam_principals`, `readwrite_aws_iam_principals`, `read_aws_iam_principals` で行う。
  - `admin_aws_iam_principals` では、S3 Bucket / S3 Objectのすべての権限を付与する。
  - `readwrite_aws_iam_principals` では、S3 Bucketの読み取り権限と、S3 ObjectのACL/Lifecycle系の変更権限以外のすべての権限を付与する。
  - `read_aws_iam_principals` では、S3 Bucketの読み取り権限と、S3 Objectの読み取り権限を付与する。
- これらの結果、`admin_aws_iam_principals`, `readwrite_aws_iam_principals` `read_aws_iam_principals` で指定されたIAM Principal以外からのBucket全体へアクセスができなくなる。
DESC
}


#======================
# convert
locals {
  admin_aws_iam_principals = [
    for p in var.admin_aws_iam_principals :
    {
      arn       = p.arn
      name      = p.name
      unique_id = p.unique_id != null ? p.unique_id : p.user_id
    }
  ]

  readwrite_aws_iam_principals = [
    for p in var.readwrite_aws_iam_principals :
    {
      arn       = p.arn
      name      = p.name
      unique_id = p.unique_id != null ? p.unique_id : p.user_id
    }
  ]

  read_aws_iam_principals = [
    for p in var.read_aws_iam_principals :
    {
      arn       = p.arn
      name      = p.name
      unique_id = p.unique_id != null ? p.unique_id : p.user_id
    }
  ]
}
