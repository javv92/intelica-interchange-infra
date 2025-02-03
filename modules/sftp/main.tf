module "sftp_server" {
  source = "../../../../modules/intelica-module-transfer-family/sftp-s3-server"

  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name


  subnet_ids             = var.subnet_ids
  vpc_id                 = var.vpc_id
  region                 = var.region
  name                   = var.name
  certificate_arn        = var.certificate_arn
  domain                 = "S3"
  is_internet_facing     = true
  custom_host_name       = var.custom_host_name
  hosted_zone_id         = var.hosted_zone_id
  allowed_cidr           = var.allowed_cidr
  allowed_security_group = var.allowed_security_group
  buckets                = var.buckets
  users                  = var.users
}
