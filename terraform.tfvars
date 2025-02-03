global_tags = { coid : "itl", "assetid" : "0004", "apid" : "itx", "env" : "dev" }
stack_number         = "01"
prefix_resource_name = "itl-0004-itx-dev"


vpc_id = "vpc-0d3938756f28f4e87"
public_subnet_ids = ["subnet-052a977648e3cc31c", "subnet-05c6d68d95269aede"]
private_subnet_ids = ["subnet-03c689501d4de3b98", "subnet-029ae9fea8543ec50"]

sftp = {
  subnet           = "subnet-05c6d68d95269aede"
  certificate_arn  = "arn:aws:acm:us-east-1:917972781642:certificate/f6c0a0c0-4c5e-4fff-9163-514c0cf78363"
  custom_host_name = "sftp.john.cloudstudio.cloud"
  hosted_zone_id   = "Z00062881JAFYWFAUV3RC"
  allowed_cidr = { public = "0.0.0.0/0" }
  allowed_security_group = { "load balancer" = "sg-0cc0be7ce06d33ead" }
}

