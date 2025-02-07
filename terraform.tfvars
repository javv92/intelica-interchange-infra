global_tags = { coid : "itl", "assetid" : "0004", "apid" : "itx", "env" : "dev" }
stack_number         = "02"
prefix_resource_name = "itl-0004-itx-dev"


vpc_id = "vpc-0df64c1b97c48f5f7"
public_subnet_ids = ["subnet-022b68abb819d519c", "subnet-08d2d24cc77409c86"]
private_subnet_ids = ["subnet-027553d801a80ef32", "subnet-0a2d90108aa3cd292"]
restricted_subnet_ids = ["subnet-0ccad48261dae4945", "subnet-0e58fd4c134dff4f1"]

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

database = {
  snapshot_identifier = "arn:aws:rds:us-east-1:818835242461:cluster-snapshot:app-interchange-aurora-priv-cluster-dev-cluster-04-02-2025-new"
}

instance = {
  ami           = "ami-09a26b8638c36ffbb"
  instance_type = "r6g.xlarge"
  key_pair = "itx"
}