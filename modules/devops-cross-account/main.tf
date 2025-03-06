locals {
  code_deploy_application      = "${var.prefix_resource_name}-codedeploy-${var.name}-${var.stack_number}"
  code_deploy_application_role = "${local.code_deploy_application}-role"
}
resource "aws_iam_role" "role" {
  name = local.code_deploy_application_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "code_deploy_policy" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}