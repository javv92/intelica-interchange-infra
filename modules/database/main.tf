resource "aws_secretsmanager_secret" "secret" {
  name       = "example"
  kms_key_id = var.kms_key_arn
}