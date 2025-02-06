locals {
  function_name         = "${var.prefix_resource_name}-lmbd-${var.name}-${var.stack_number}"
  function_role_name    = "${local.function_name}-role"
  python_lib_layer_name = "${var.prefix_resource_name}-lmbd-${var.name}-${var.stack_number}-pythonlibs-lyr"
  sftp_event_rule_name  = "${var.prefix_resource_name}-lmbd-${var.name}-${var.stack_number}-sftp-rule"

}

resource "aws_iam_role" "role" {
  name = local.function_role_name

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy" "cloudwatch_logs_policy" {
  name = "${local.function_role_name}-cloudwatch-logs-pol"
  role = aws_iam_role.role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Resource = "*"
        }
      ]
    }
  )
}
resource "aws_iam_role_policy" "secrets_manager_logs_policy" {
  name = "${local.function_role_name}-secrets-manager-pol"
  role = aws_iam_role.role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue",
          ]
          Resource = toset([for secret in var.secrets : secret.arn])
        },
        {
          Effect = "Allow"
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey",
          ]
          Resource = toset([for secret in var.secrets : secret.kms_key_arn])
        }
      ]
    }
  )
}
resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "${path.module}/layers/python-libs.zip"
  layer_name = local.python_lib_layer_name

  compatible_runtimes = ["python3.10"]
}
resource "aws_lambda_function" "function" {
  function_name = local.function_name
  role          = aws_iam_role.role.arn
  handler       = "lambda_fileload_rds.lambda_handler"
  runtime       = "python3.10"
  timeout       = 3
  filename      = "${path.module}/src.zip"
  source_code_hash = filebase64sha256("${path.module}/src.zip")
  environment {
    variables = {
    }
  }
  layers = [
    aws_lambda_layer_version.lambda_layer.arn,
    # "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python310:16"
  ]
}

resource "aws_cloudwatch_event_rule" "sft_event_rule" {
  name        = local.sftp_event_rule_name
  description = local.sftp_event_rule_name

  event_pattern = jsonencode({
    source = ["aws.transfer"]
    detail-type = ["SFTP Server File Upload Failed", "SFTP Server File Upload Completed"],
    detail = {
      server-id = [var.sftp_server_id]
    }
  })
}

resource "aws_cloudwatch_event_target" "sft_event_rule_target" {
  rule      = aws_cloudwatch_event_rule.sft_event_rule.name
  target_id = "Lambda"
  arn       = aws_lambda_function.function.arn
}
resource "aws_lambda_permission" "event_bridge" {
  statement_id  = "AllowExecutionFromEventBridgeSftpRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sft_event_rule.arn
}