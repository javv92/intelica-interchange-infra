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
resource "aws_iam_role_policy" "source_s3_policy" {
  name = "${local.function_role_name}-source-s3-pol"
  role = aws_iam_role.role.id

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "s3:ListBucket"
          ],
          Effect   = "Allow",
          Resource = [for bucket in var.sources.buckets : bucket.arn]
        },
        {
          Action = [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:GetObjectAcl",
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
          ],
          Effect   = "Allow",
          Resource = [
            for bucket in var.sources.buckets :join("/", compact(split("/", "${bucket.arn}/${bucket.prefix}*")))
          ]
          # Resource = [for bucket in var.sources.buckets : replace("${bucket.arn}/${bucket.prefix}*", "//", "/")]
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
          Resource = toset([for bucket in var.sources.buckets : bucket.kms_key_arn])
        }
      ]
    }
  )
}
resource "aws_iam_role_policy" "target_sqs_policy" {
  name = "${local.function_role_name}-target-sqs-pol"
  role = aws_iam_role.role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Effect = "Allow"
          Action = [
            "sqs:SendMessage",
            "sqs:GetQueueAttributes"
          ]
          Resource = toset([for queue in var.targets.queues : queue.arn])
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
          Resource = toset([for queue in var.targets.queues : queue.kms_key_arn])
        }
      ]
    }
  )
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
resource "aws_lambda_function" "function" {
  function_name = local.function_name
  role          = aws_iam_role.role.arn
  handler       = "trigger_app.lambda_handler"
  runtime       = "python3.10"
  timeout       = 3
  filename      = "${path.module}/src.zip"
  source_code_hash = filebase64sha256("${path.module}/src.zip")
  environment {
    variables = {
      QUEUES_URL_MAP = jsonencode({
        for k, v in var.targets.queues : k => replace(
          v.arn,
          "/^arn:aws:sqs:(.*):(.*):(.*)/",
          "https://sqs.$1.amazonaws.com/$2/$3"
        )
      })
    }
  }
  kms_key_arn = var.kms_key_arn
}

resource "aws_s3_bucket_notification" "bucket_lambda_trigger" {
  for_each = var.sources.buckets
  bucket   = split(":", each.value.arn)[length(split(":", each.value.arn)) - 1]
  lambda_function {
    lambda_function_arn = aws_lambda_function.function.arn
    events = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "bucket_invoke_permission" {
  for_each      = var.sources.buckets
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = each.value.arn
}