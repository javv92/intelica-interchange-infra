resource "aws_secretsmanager_secret" "secret" {
  name       = "${var.prefix_resource_name}-secret-smtp-${var.name}-${var.stack_number}"
  kms_key_id = var.kms_key_arn
}