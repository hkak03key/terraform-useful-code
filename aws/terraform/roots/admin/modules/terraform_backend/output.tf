output "aws_iam_role_github_actions" {
  value = {
    for k, v in var.aws_iam_role_github_actions_config :
    k => module.aws_iam_role_github_actions[k] if v.is_output
  }
}
