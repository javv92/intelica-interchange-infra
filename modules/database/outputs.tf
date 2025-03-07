output "secret_arn" {
  value = module.cluster_rds_serverless.secret_arn
}
output "secret_kms_key_id" {
  value = module.cluster_rds_serverless.secret_kms_key_id
}
output "security_group_id" {
  value = module.cluster_rds_serverless.security_group_id
}