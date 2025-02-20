module "sftp_server" {
  # source = "../../../../modules/intelica-module-transfer-family/sftp-s3-server"
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-transfer-family//sftp-s3-server"

  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name


  subnet_ids         = var.subnet_ids
  vpc_id             = var.vpc_id
  region             = var.region
  name               = var.name
  certificate_arn    = var.certificate_arn
  domain             = "S3"
  is_internet_facing = true
  custom_host_name   = var.custom_host_name
  hosted_zone_id     = var.hosted_zone_id
  buckets            = var.buckets
  users = {
    usr_cdno = {
      home_directory = {
        bucket_key = "landing"
        prefix     = "CNDO"
      }
    }
  }
  security_group = {
    ingress = merge(
      {for k, v in var.allowed_cidr : k => { cidr = v }},
      {for k, v in var.allowed_security_group : k => { security_group = v }}
    )
  }
}
