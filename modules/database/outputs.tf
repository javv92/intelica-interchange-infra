output "secret_arn" {
  value = aws_secretsmanager_secret.secret.arn
}
output "secret_kms_key_id" {
  value = aws_secretsmanager_secret.secret.kms_key_id
}
output "security_group_id" {
  value = module.cluster_rds_serverless.security_group_id
}