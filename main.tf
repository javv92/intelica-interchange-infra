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
  buckets = {
    landing = {
      arn         = module.storage.landing_bucket_arn
      kms_key_arn = module.storage.landing_bucket_kms_key_arn
    }
  }
}
module "sftp_nlb" {
  source = "./modules/sftp-nlb"

  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name

  name                   = "sftp"
  vpc_id                 = var.vpc_id
  subnet_ids             = var.public_subnet_ids
  is_internet_facing     = "true"
  certificate_arn        = var.sftp_nlb.certificate_arn
  custom_host_name       = var.sftp_nlb.custom_host_name
  hosted_zone_id         = var.sftp_nlb.hosted_zone_id
  allowed_cidr           = var.sftp.allowed_cidr
  allowed_security_group = var.sftp.allowed_security_group
  sftp_server_ips = module.sftp.server_ips

}
module "main_queue" {
  source = "./modules/main-queue"

  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  name                 = "app"
  kms_key_arn          = module.base.key_arn
}

module "database" {
  source = "./modules/database"

  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  name                 = "app"
  kms_key_arn          = module.base.key_arn
}
module "main_lambda" {
  source = "./modules/main-lambda"

  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  name                 = "app"

  sources = {
    buckets = {
      landing = {
        arn         = module.storage.landing_bucket_arn
        kms_key_arn = module.storage.landing_bucket_kms_key_arn
      }
    }
  }
  targets = {
    queues = {
      btro = {
        arn         = module.main_queue.btro_queue_arn
        kms_key_arn = module.main_queue.btro_kms_key_arn
      }
      cndo = {
        arn         = module.main_queue.cndo_queue_arn
        kms_key_arn = module.main_queue.cndo_kms_key_arn
      }
      ebgr = {
        arn         = module.main_queue.ebgr_queue_arn
        kms_key_arn = module.main_queue.ebgr_kms_key_arn
      }
      fihn = {
        arn         = module.main_queue.fihn_queue_arn
        kms_key_arn = module.main_queue.fihn_kms_key_arn
      }
      fope = {
        arn         = module.main_queue.fope_queue_arn
        kms_key_arn = module.main_queue.fope_kms_key_arn
      }
      gnmx = {
        arn         = module.main_queue.gnmx_queue_arn
        kms_key_arn = module.main_queue.gnmx_kms_key_arn
      }
      inpe = {
        arn         = module.main_queue.inpe_queue_arn
        kms_key_arn = module.main_queue.inpe_kms_key_arn
      }
      sbpe = {
        arn         = module.main_queue.sbpe_queue_arn
        kms_key_arn = module.main_queue.sbpe_kms_key_arn
      }
      sbsa = {
        arn         = module.main_queue.sbsa_queue_arn
        kms_key_arn = module.main_queue.sbsa_kms_key_arn
      }
      ucit = {
        arn         = module.main_queue.ucit_queue_arn
        kms_key_arn = module.main_queue.ucit_kms_key_arn
      }
    }
  }
}
