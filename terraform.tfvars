global_tags = { coid : "itl", "assetid" : "0004", "apid" : "itx", "env" : "dev" }
stack_number         = "01"
prefix_resource_name = "itl-0004-itx-dev"


vpc_id = "vpc-0fe1bde56eb2cb8a3"
public_subnet_ids = ["subnet-0090144bac3a064cf", "subnet-08b0ca3938a845ea0"]
private_subnet_ids = ["subnet-0abb425bb9d52d496", "subnet-0248461e04fd6dc1a"]
restricted_subnet_ids = ["subnet-0c9311088ec410989", "subnet-00d947574978b7c74"]

sftp = {
  enabled = false
  subnet           = "subnet-08b0ca3938a845ea0"
  certificate_arn  = "arn:aws:acm:us-east-1:861276092327:certificate/39200c52-8ffd-4ac1-b59c-a9c71f1204c3"
  custom_host_name = "sftp.dev.itx.intelica.com"
  hosted_zone_id   = "Z07319932HJTN65P3SNJ2"
  allowed_cidr = { public = "0.0.0.0/0" }
}

sftp_nlb = {
  # certificate_arn  = "arn:aws:acm:us-east-1:861276092327:certificate/39200c52-8ffd-4ac1-b59c-a9c71f1204c3"
  enabled = false
  custom_host_name = "sftpx.dev.itx.intelica.com"
  hosted_zone_id   = "Z07319932HJTN65P3SNJ2"
  allowed_cidr = { public = "0.0.0.0/0" }
}

database = {
  snapshot_identifier = "arn:aws:rds:us-east-1:818835242461:cluster-snapshot:app-interchange-aurora-priv-cluster-dev-cluster-04-02-2025-new"
  allowed_cidr = { "FortiClient ingress" = "10.0.3.100/32" }
}

instance = {
  ami           = "ami-09a26b8638c36ffbb"
  instance_type = "r6g.xlarge"
  key_pair      = "itl-0004-itx-dev-ec2-app-01"
  allowed_cidr = {
    all_traffic = {
      "FORTIVPN ingress"  = "10.0.3.100/32"
      "FortiSIEM ingress" = "100.0.4.38/32"
    }
    ssh = {
      "Accesos ssh" = "0.0.0.0/0"
    }
  }
}

opensearch = {
  engine_version = "OpenSearch_2.3"
  instance_type  = "t3.small.search"
  storage_size   = 60
  instance_count = 3
}