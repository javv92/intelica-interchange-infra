global_tags = { coid : "itl", "assetid" : "0004", "apid" : "itx", "env" : "dev" }
stack_number         = "02"
prefix_resource_name = "itl-0004-itx-dev"


vpc_id = "vpc-0df64c1b97c48f5f7"
public_subnet_ids = ["subnet-022b68abb819d519c", "subnet-08d2d24cc77409c86"]
private_subnet_ids = ["subnet-027553d801a80ef32", "subnet-0a2d90108aa3cd292"]

sftp = {
  subnet           = "subnet-08d2d24cc77409c86"
  certificate_arn  = "arn:aws:acm:us-east-1:891376942769:certificate/f5ccf16b-ee24-43b4-b1f8-ce19eaa67ccc"
  custom_host_name = "sftp.dev.intelica.com "
  hosted_zone_id   = "Z01574663NHZJL1H40WUD"
  allowed_cidr = { public = "0.0.0.0/0" }
}

sftp_nlb = {
  certificate_arn  = "arn:aws:acm:us-east-1:891376942769:certificate/f5ccf16b-ee24-43b4-b1f8-ce19eaa67ccc"
  custom_host_name = "sftpx.dev.intelica.com "
  hosted_zone_id   = "Z01574663NHZJL1H40WUD"
  allowed_cidr = { public = "0.0.0.0/0" }
}