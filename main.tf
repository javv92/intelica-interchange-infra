module "base" {
  source = "./modules/base"

  name                 = "general"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
}
module "storage" {
  source = "./modules/storage"

  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  key_arn              = module.base.key_arn
}

module "sftp" {
  source = "./modules/sftp"

  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  subnet_ids = [var.sftp.subnet]
  vpc_id               = var.vpc_id

  region                 = "us-east-1"
  name                   = "sftp"
  certificate_arn        = var.sftp.certificate_arn
  custom_host_name       = var.sftp.custom_host_name
  hosted_zone_id         = var.sftp.hosted_zone_id
  allowed_cidr           = var.sftp.allowed_cidr
  allowed_security_group = var.sftp.allowed_security_group
}
