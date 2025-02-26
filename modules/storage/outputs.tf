output "enriched_bucket_name" {
  value = module.enriched.s3_bucket_id
}
output "enriched_bucket_arn" {
  value = module.enriched.s3_bucket_arn
}
output "enriched_bucket_kms_key_arn" {
  value = module.enriched.kms_key_arn
}
output "landing_bucket_name" {
  value = module.landing.s3_bucket_id
}
output "landing_bucket_arn" {
  value = module.landing.s3_bucket_arn
}
output "landing_bucket_kms_key_arn" {
  value = module.landing.kms_key_arn
}
output "log_bucket_name" {
  value = module.log.s3_bucket_id
}
output "log_bucket_arn" {
  value = module.log.s3_bucket_arn
}
output "log_bucket_kms_key_arn" {
  value = module.log.kms_key_arn
}
output "operational_bucket_name" {
  value = module.operational.s3_bucket_id
}
output "operational_bucket_arn" {
  value = module.operational.s3_bucket_arn
}
output "operational_bucket_kms_key_arn" {
  value = module.operational.kms_key_arn
}
output "row_bucket_name" {
  value = module.row.s3_bucket_id
}
output "row_bucket_arn" {
  value = module.row.s3_bucket_arn
}
output "row_bucket_kms_key_arn" {
  value = module.row.kms_key_arn
}
output "structured_bucket_name" {
  value = module.structured.s3_bucket_id
}
output "structured_bucket_arn" {
  value = module.structured.s3_bucket_arn
}
output "structured_bucket_kms_key_arn" {
  value = module.structured.kms_key_arn
}
output "scheme_fee_bucket_name" {
  value = module.scheme-fee.s3_bucket_id
}
output "scheme_fee_bucket_arn" {
  value = module.scheme-fee.s3_bucket_arn
}
output "scheme_fee_bucket_kms_key_arn" {
  value = module.scheme-fee.kms_key_arn
}