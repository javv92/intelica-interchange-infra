locals {
  function_name      = "${var.prefix_resource_name}-lmbd-${var.name}-${var.stack_number}"
  function_role_name = "${local.function_name}-role"
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
resource "aws_iam_role_policy" "secrets_manager_policy" {
  name = "${local.function_role_name}-secrets-pol"
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
          Resource = toset([var.secrets.smtp.arn])
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
          Resource = toset([var.secrets.smtp.kms_key_arn])
        }
      ]
    }
  )
}
resource "aws_lambda_function" "function" {
  function_name = local.function_name
  role          = aws_iam_role.role.arn
  handler       = "src/lambda_function.lambda_handler"
  runtime       = "python3.10"
  timeout       = 3
  filename      = "${path.module}/src.zip"
  source_code_hash = filebase64sha256("${path.module}/src.zip")
  environment {
    variables = {
      SMTP_SECRET_ARN = var.secrets.smtp.arn
    }
  }

  kms_key_arn = var.kms_key_arn
}