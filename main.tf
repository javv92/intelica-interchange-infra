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
  is_internet_facing     = true
  certificate_arn        = var.sftp_nlb.certificate_arn
  custom_host_name       = var.sftp_nlb.custom_host_name
  hosted_zone_id         = var.sftp_nlb.hosted_zone_id
  allowed_cidr           = var.sftp.allowed_cidr
  allowed_security_group = var.sftp.allowed_security_group
  sftp_server_ips        = module.sftp.server_ips

  depends_on = [module.sftp]

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
  database_subnet_ids  = var.restricted_subnet_ids
  snapshot_identifier  = var.database.snapshot_identifier
  vpc_id               = var.vpc_id
  allowed_cidr = var.database.allowed_cidr
  allowed_security_group = var.database.allowed_security_group
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
module "fileload-lambda" {
  source               = "./modules/fileload-lambda"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  name                 = "file-load"
  sftp_server_id       = module.sftp.server_id
  secrets = {
    interchange_database = {
      arn         = module.database.secret_arn
      kms_key_arn = module.database.secret_kms_key_id
    }
  }
  bucket_name = module.storage.landing_bucket_name
  subnet_ids  = var.private_subnet_ids
  vpc_id      = var.vpc_id
}
resource "aws_vpc_security_group_ingress_rule" "file_load_lambda_to_database_security_group_ingress" {
  security_group_id            = module.database.security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.fileload-lambda.security_group_id
  description                  = "access to lambda function ${module.fileload-lambda.function_name}"
  tags = { Name : module.fileload-lambda.function_name }
}


module "instance" {
  source               = "./modules/ec2-instance"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  name                 = "app"

  subnet_id              = var.private_subnet_ids[0]
  vpc_id                 = var.vpc_id
  ami                    = var.instance.ami
  instance_type          = var.instance.instance_type
  kms_key_arn            = module.base.key_arn
  key_pair               = var.instance.key_pair
  allowed_cidr           = var.instance.allowed_cidr
  allowed_security_group = var.instance.allowed_security_group

  secrets = {
    interchange_database = {
      arn         = module.database.secret_arn
      kms_key_arn = module.database.secret_kms_key_id
    }
  }

  buckets = {
    landing = {
      arn         = module.storage.landing_bucket_arn
      kms_key_arn = module.storage.landing_bucket_kms_key_arn
    }
    enriched = {
      arn         = module.storage.enriched_bucket_arn
      kms_key_arn = module.storage.enriched_bucket_kms_key_arn
    }
    log = {
      arn         = module.storage.log_bucket_arn
      kms_key_arn = module.storage.log_bucket_kms_key_arn
    }
    operational = {
      arn         = module.storage.operational_bucket_arn
      kms_key_arn = module.storage.operational_bucket_kms_key_arn
    }
    row = {
      arn         = module.storage.row_bucket_arn
      kms_key_arn = module.storage.row_bucket_kms_key_arn
    }
    structured = {
      arn         = module.storage.structured_bucket_arn
      kms_key_arn = module.storage.structured_bucket_kms_key_arn
    }
  }
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
  lambda = {
    send_mail = {
      arn = module.sendmail-lambda.function_arn
    }
  }
}

resource "aws_vpc_security_group_ingress_rule" "instance_to_database_security_group_ingress" {
  security_group_id            = module.database.security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.instance.security_group_id
  description                  = "access to ec2 instance ${module.instance.instance_name}"
  tags = { Name : module.instance.instance_name }
}
module "smtp" {
  source               = "./modules/smtp"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  name                 = "app"
  kms_key_arn          = module.base.key_arn
}
module "sendmail-lambda" {
  source               = "./modules/send-mail-lambda"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  name                 = "sendmail"
  secrets = {
    smtp = {
      arn         = module.smtp.secret_arn
      kms_key_arn = module.smtp.secret_kms_key_id
    }
  }
}
module "opensearch" {
  source               = "./modules/opensearch"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = module.base.key_arn
  engine_version       = var.opensearch.engine_version
  instance_type        = var.opensearch.instance_type
  storage_size         = var.opensearch.storage_size
  instance_count       = var.opensearch.instance_count
}