# KMS

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
  count = var.artifact_bucket != null ? 1 : 0
  name  = "s3-devops-artifact-pol"
  role  = var.ec2_app.instance_role

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

# MAIN LAMBDA FUNCTION
resource "aws_lambda_permission" "main_lambda_update_code" {
  statement_id  = "AllowUpdateFromDevopsAccount"
  action        = "lambda:UpdateFunctionCode"
  function_name = var.main_lambda.function_arn
  principal     = "arn:aws:iam::${var.devops_account}:root"
}


resource "aws_lambda_permission" "main_lambda_get_lambda" {
  statement_id  = "AllowGetFunctionFromAnotherAccount"
  action        = "lambda:GetFunction"
  function_name = var.main_lambda.function_arn
  principal     = "arn:aws:iam::${var.devops_account}:root"
}

resource "aws_lambda_permission" "main_lambda_update_conf" {
  statement_id  = "AllowUpdateConfigFromAnotherAccount"
  action        = "lambda:UpdateFunctionConfiguration"
  function_name = var.main_lambda.function_arn
  principal     = "arn:aws:iam::${var.devops_account}:root"
}