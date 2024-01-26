locals {
  # 相対パスを絶対パスに変換する
  aws_iam_policy_infos_dir = (
    startswith(var.aws_iam_policy_infos_dir, "/")
    ? var.aws_iam_policy_infos_dir
    : abspath("${path.module}/${var.aws_iam_policy_infos_dir}")
  )
}
