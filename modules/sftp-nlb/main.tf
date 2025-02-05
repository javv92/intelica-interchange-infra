module "sftp_nlb" {
  source = "../../../../modules/intelica-module-load-balancer/network-load-balancer"

  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name


  subnet_ids         = var.subnet_ids
  vpc_id             = var.vpc_id
  name               = var.name
  # certificate_arn    = var.certificate_arn
  is_internet_facing = var.is_internet_facing
  custom_host_name   = var.custom_host_name
  hosted_zone_id     = var.hosted_zone_id

  security_group = {
    ingress = merge(
      {for k, v in var.allowed_cidr : k => { cidr = v, protocol = "tcp", from_port = 2222, to_port = 2222 }},
      {
        for k, v in var.allowed_security_group : k =>
        { security_group = v, protocol = "tcp", from_port = 2222, to_port = 2222 }
      }
    )
  }
}
