locals {
  devops_role_name = "${var.prefix_resource_name}-iam-${var.name}-${var.stack_number}"
}
# EC2 APP
module "ec2_app_application" {
  source               = "../../../../modules/intelica-module-codedeploy/application"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  compute_platform     = "Server"
  name                 = "ec2-app"
}

module "ec2_app_deployment_group" {
  for_each             = var.ec2_app.deployments
  source               = "../../../../modules/intelica-module-codedeploy/deployment_group_ec2_instance_in_place"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  name                 = "ec2-app-${each.key}"

  codedeploy_application_arn = module.ec2_app_application.application_arn
  deployment_config_name     = each.value.config_name
  ec2_tags                   = each.value.tags
  artifact_bucket            = var.artifact_bucket
}

resource "aws_iam_role_policy" "app_ec2_devops_artifact_policy" {
  name = "s3-devops-artifact-pol"
  role = var.ec2_app.instance_role

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = concat(
        [
          {
            Action = [
              "s3:List*"
            ],
            Effect = "Allow",
            Resource = [
              var.artifact_bucket.arn
            ]
          },
          {
            Action = [
              "s3:Get*"
            ],
            Effect = "Allow",
            Resource = [
              join("/", compact(split("/", "${var.artifact_bucket.arn}/${var.artifact_bucket.prefix}*")))
            ]
          }
        ],
          var.artifact_bucket.kms_key_arn != null ? [
          {
            Effect = "Allow"
            Action = [
              "kms:Decrypt",
              "kms:GenerateDataKey*",
              "kms:DescribeKey",
            ]
            Resource = toset([var.artifact_bucket.kms_key_arn])
          }
        ] : []
      )
    }
  )
}

resource "aws_iam_role" "role" {
  name = local.devops_role_name

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.devops_account}:root"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_deploy" {
  name = "lambda_deploy"
  role = aws_iam_role.role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:GetFunction"
        ]
        Resource = [var.main_lambda.function_arn]
      }
    ],
        var.main_lambda.kms_key_arn != null ? [
        {
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:GenerateDataKey*",
            "kms:DescribeKey",
          ]
          Resource = toset([var.main_lambda.kms_key_arn])
        }
      ] : [])
  })
}


resource "aws_iam_role_policy" "code_deploy" {
  name = "codedeploy_deploy"
  role = aws_iam_role.role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:GetApplicationRevision",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetApplication"
        ]
        Resource = concat(
          [
            module.ec2_app_application.application_arn,
            "arn:aws:codedeploy:*:*:deploymentconfig:*"
          ],
          [for deployment in module.ec2_app_deployment_group : deployment.deployment_group_arn]
        )
      }
    ]
  })
}

resource "aws_iam_role_policy" "code_deploy_devops_artifact_policy" {
  name = "s3-devops-artifact-pol"
  role = aws_iam_role.role.id

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = concat(
        [
          {
            Action = [
              "s3:List*"
            ],
            Effect = "Allow",
            Resource = [
              var.artifact_bucket.arn
            ]
          },
          {
            Action = [
              "s3:Get*"
            ],
            Effect = "Allow",
            Resource = [
              join("/", compact(split("/", "${var.artifact_bucket.arn}/${var.artifact_bucket.prefix}*")))
            ]
          }
        ],
          var.artifact_bucket.kms_key_arn != null ? [
          {
            Effect = "Allow"
            Action = [
              "kms:Decrypt",
              "kms:GenerateDataKey*",
              "kms:DescribeKey",
            ]
            Resource = toset([var.artifact_bucket.kms_key_arn])
          }
        ] : []
      )
    }
  )
}