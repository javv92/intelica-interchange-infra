module instance {
  source               = "../../../../modules/intelica-module-ec2/instance"
  name                 = var.name
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.kms_key_arn

  ami           = var.ami
  instance_type = var.instance_type
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  security_group = {
    ingress = merge(
      # ALL TRAFFIC
      {for k, v in var.allowed_cidr.all_traffic : k => { cidr = v, protocol = -1, port = -1 }},
      {for k, v in var.allowed_security_group.all_traffic : k => { security_group = v, protocol = -1, port = -1 }},
      # SSH
      {for k, v in var.allowed_cidr.ssh : k => { cidr = v, protocol = "TCP", port = 22 }},
      {for k, v in var.allowed_security_group.ssh : k => { security_group = v, protocol = "TCP", port = 22 }},
    )
  }
  key_pair = var.key_pair
}
resource "aws_iam_role_policy" "secrets_manager_policy" {
  name = "${module.instance.role_name}-secrets-pol"
  role = module.instance.role_name

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
resource "aws_iam_role_policy" "s3_policy" {
  name = "${module.instance.role_name}-s3-pol"
  role = module.instance.role_name

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "s3:ListBucket"
          ],
          Effect   = "Allow",
          Resource = [for bucket in var.buckets : bucket.arn]
        },
        {
          Action = [
            "s3:GetBucketLocation",
            "s3:ListBucket",
            "s3:GetObject",
            "s3:GetObjectAcl",
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
          ],
          Effect   = "Allow",
          Resource = [
            for bucket in var.buckets :join("/", compact(split("/", "${bucket.arn}/${bucket.prefix}*")))
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
          Resource = toset([for bucket in var.buckets : bucket.kms_key_arn])
        }
      ]
    }
  )
}
resource "aws_iam_role_policy" "sqs_policy" {
  name = "${module.instance.role_name}-sqs-pol"
  role = module.instance.role_name

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
          Resource = toset([for queue in var.queues : queue.arn])
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
          Resource = toset([for queue in var.queues : queue.kms_key_arn])
        }
      ]
    }
  )
}
