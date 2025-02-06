terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
locals {
  function_name                = "${var.prefix_resource_name}-lmbd-${var.name}-${var.stack_number}"
  function_role_name           = "${local.function_name}-role"
  function_security_group_name = "${local.function_name}-sg"
  python_lib_layer_name        = "${var.prefix_resource_name}-lmbd-${var.name}-${var.stack_number}-pythonlibs-lyr"
  sftp_event_rule_name         = "${var.prefix_resource_name}-lmbd-${var.name}-${var.stack_number}-sftp-rule"

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
          Resource = toset([var.secrets.interchange_database.arn])
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
          Resource = toset([var.secrets.interchange_database.kms_key_arn])
        }
      ]
    }
  )
}
resource "aws_iam_role_policy" "vpc_policy" {
  name = "${local.function_role_name}-vpc-pol"
  role = aws_iam_role.role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeSubnets",
            "ec2:DeleteNetworkInterface",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses"
          ],
          "Resource" : ["*"]
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
resource "aws_security_group" "security_group" {
  name        = local.function_security_group_name
  description = local.function_security_group_name
  vpc_id      = var.vpc_id
  tags = {
    Name = local.function_security_group_name
  }
}
resource "aws_vpc_security_group_egress_rule" "all_traffic_egress" {
  security_group_id = aws_security_group.security_group.id
  from_port         = -1
  to_port           = -1
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
  tags = { Name : "All traffic" }
}
resource "aws_lambda_function" "function" {
  function_name = local.function_name
  role          = aws_iam_role.role.arn
  handler       = "src/lambda_fileload_rds.lambda_handler"
  runtime       = "python3.10"
  timeout       = 3
  filename      = "${path.module}/src.zip"
  source_code_hash = filebase64sha256("${path.module}/src.zip")
  vpc_config {
    security_group_ids = [aws_security_group.security_group.id]
    subnet_ids = var.subnet_ids
  }
  environment {
    variables = {
      INTERCHANGE_DATABASE_SECRET_ARN = var.secrets.interchange_database.arn
      BUCKET_NAME                     = var.bucket_name
    }
  }
  layers = [
    aws_lambda_layer_version.lambda_layer.arn,
    "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python310:16"
  ]
  depends_on = [
    aws_iam_role_policy.vpc_policy
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