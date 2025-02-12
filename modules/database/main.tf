resource "aws_secretsmanager_secret" "secret" {
  name       = "${var.prefix_resource_name}-secret-database-${var.name}-${var.stack_number}"
  kms_key_id = var.kms_key_arn
}
module "cluster_rds_serverless" {
  source = "../../../../modules/intelica-module-rds/aurora-postgresql"

  name                 = var.name
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name

  snapshot_identifier     = var.snapshot_identifier
  kms_key_arn             = var.kms_key_arn
  vpc_id                  = var.vpc_id
  subnet_ids              = var.database_subnet_ids
  allowed_security_groups = var.allowed_security_groups
  allowed_cidr_blocks     = var.allowed_cidr_blocks
  db_cluster_parameters   = var.db_cluster_parameters
  engine_version          = "16.2"
}
