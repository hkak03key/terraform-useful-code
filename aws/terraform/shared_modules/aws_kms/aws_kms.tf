/************************
# KMS
************************/
resource "aws_kms_key" "default" {
  enable_key_rotation = true

  policy = data.aws_iam_policy_document.kms_policy.json
}


resource "aws_kms_alias" "default" {
  name          = "alias/${local.name_prefix}"
  target_key_id = aws_kms_key.default.key_id
}


/************************
# KMS Policy
ref:
- https://docs.aws.amazon.com/ja_jp/kms/latest/developerguide/key-policy-default.html
- https://aws.amazon.com/jp/premiumsupport/knowledge-center/kms-prevent-access/
************************/
locals {
  user_aws_iam_principals = (
    var.enable_access_as_user_by_admin
    ? flatten([
      var.user_aws_iam_principals,
      var.admin_aws_iam_principals,
    ])
    : var.user_aws_iam_principals
  )
}


data "aws_iam_policy_document" "kms_policy" {
  source_policy_documents = flatten([
    # root access / iam policy access
    var.enable_access_with_iam_policy == true ? [
      # the policy of iam policy access includes root access
      data.aws_iam_policy_document.enable_access_with_iam_policy_kms_policy.json,
      ] : [
      data.aws_iam_policy_document.enable_root_access_kms_policy.json,
    ],
    # admin access
    data.aws_iam_policy_document.allow_access_for_key_administrators_kms_policy.json,
    # user access
    length(local.user_aws_iam_principals) > 0 ? [
      data.aws_iam_policy_document.allow_use_of_the_key_kms_policy.json,
      data.aws_iam_policy_document.allow_attachment_of_persistent_resources_kms_policy.json,
    ] : [],
    # additional kms policy
    var.additional_kms_policy != null ? [
      var.additional_kms_policy,
    ] : [],
  ])
}


data "aws_iam_policy_document" "enable_access_with_iam_policy_kms_policy" {
  source_policy_documents = [templatefile(
    "${path.module}/aws_policies/enable_access_with_iam_policy_kms_policy.json.tftpl",
    {
      aws_account_id = local.aws_account_id
    }
  )]
}


data "aws_iam_policy_document" "enable_root_access_kms_policy" {
  source_policy_documents = [templatefile(
    "${path.module}/aws_policies/enable_root_access_kms_policy.json.tftpl",
    {
      aws_account_id = local.aws_account_id
    }
  )]
}


data "aws_iam_policy_document" "allow_access_for_key_administrators_kms_policy" {
  source_policy_documents = [templatefile(
    "${path.module}/aws_policies/allow_access_for_key_administrators_kms_policy.json.tftpl",
    {
      admin_aws_iam_principal_arns = toset([
        for p in var.admin_aws_iam_principals : p.arn
      ])
    }
  )]
}


# FIXME: HMAC KMS key に対応していない
data "aws_iam_policy_document" "allow_use_of_the_key_kms_policy" {
  source_policy_documents = [templatefile(
    "${path.module}/aws_policies/allow_use_of_the_key_kms_policy.json.tftpl",
    {
      user_aws_iam_principal_arns = toset([
        for p in local.user_aws_iam_principals : p.arn
      ])
    }
  )]
}


data "aws_iam_policy_document" "allow_attachment_of_persistent_resources_kms_policy" {
  source_policy_documents = [templatefile(
    "${path.module}/aws_policies/allow_attachment_of_persistent_resources_kms_policy.json.tftpl",
    {
      user_aws_iam_principal_arns = toset([
        for p in local.user_aws_iam_principals : p.arn
      ])
    }
  )]
}

