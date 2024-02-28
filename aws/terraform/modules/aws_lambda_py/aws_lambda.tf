locals {
  # for preventing cyclic dependency
  aws_lambda_function_function_name = replace(
    join("-", [local.name_prefix]),
    "_",
    "-"
  )
}

/*
layer for install package
*/
data "external" "create_venv_for_layer" {
  program = ["bash", "${path.module}/script/create_venv_for_layer.sh"]
}


data "archive_file" "layer" {
  type        = "zip"
  source_dir  = data.external.create_venv_for_layer.result["path"]
  output_path = "${data.external.create_venv_for_layer.result["path"]}.zip"

  depends_on = [
    data.external.create_venv_for_layer,
  ]
}


resource "aws_lambda_layer_version" "default" {
  layer_name = replace(
    join("-", [local.name_prefix]),
    "_",
    "-"
  )

  filename         = data.archive_file.layer.output_path
  source_code_hash = data.archive_file.layer.output_base64sha256

  compatible_runtimes = ["python3.10"]
}


/*
lambda function
*/
data "archive_file" "default" {
  type        = "zip"
  source_dir  = "${path.module}/script/script"
  output_path = "${path.module}/script/.build/script.zip"
}


resource "aws_lambda_function" "default" {
  function_name = local.aws_lambda_function_function_name

  filename         = data.archive_file.default.output_path
  source_code_hash = data.archive_file.default.output_base64sha256

  handler = "main.lambda_handler"
  runtime = "python3.10"

  layers = [aws_lambda_layer_version.default.arn]

  role = aws_iam_role.default.arn

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.default,
    aws_iam_role_policy_attachment.default,
  ]
}


/*
iam role
*/
resource "aws_iam_role" "default" {
  name = replace(
    join("-", [local.name_prefix]),
    "_",
    "-"
  )
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "default" {
  for_each = {
    for aws_iam_policy in [
      aws_iam_policy.logs_log,
    ] : aws_iam_policy.name => aws_iam_policy.arn
  }

  role       = aws_iam_role.default.name
  policy_arn = each.value
}


/*
iam policy
*/
locals {
  _aws_iam_policy_aws_lambda_function_default = jsondecode(
    templatefile(
      "${var.aws_iam_policy_infos_dir}/lambda_exec.json.tftpl",
      {
        # iam policyに関する情報
        iam_policy_aws_account_id = local.aws_account_id
        # アクセスしたいリソースに関する情報
        resource_aws_account_id = local.aws_account_id
        resource_region         = local.region
        resource_name           = local.aws_lambda_function_function_name
      }
    )
  )
}


resource "aws_iam_policy" "lambda_exec" {
  name        = local._aws_iam_policy_aws_lambda_function_default["name"]
  path        = "/"
  description = ""

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(local._aws_iam_policy_aws_lambda_function_default["policy"])
}
