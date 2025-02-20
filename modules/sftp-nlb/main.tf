module "sftp_nlb" {
  # source = "../../../../modules/intelica-module-load-balancer/network-load-balancer"
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-load-balancer//network-load-balancer"

  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name


  subnet_ids         = var.subnet_ids
  vpc_id             = var.vpc_id
  name = var.name
  # certificate_arn    = var.certificate_arn
  is_internet_facing = var.is_internet_facing
  custom_host_name   = var.custom_host_name
  hosted_zone_id     = var.hosted_zone_id

  # security_group = {
  #   ingress = merge(
  #     {for k, v in var.allowed_cidr : k => { cidr = v, protocol = "tcp", from_port = 2222, to_port = 2222 }},
  #     {
  #       for k, v in var.allowed_security_group : k =>
  #       { security_group = v, protocol = "tcp", from_port = 2222, to_port = 2222 }
  #     }
  #   )
  # }
}
module "sft_server" {
  # source = "../../../../modules/intelica-module-load-balancer/network-load-balancer-ip-application"
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-load-balancer//network-load-balancer-ip-application"

  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name

  name = var.name
  # certificate_arn    = var.certificate_arn


  vpc_id                       = var.vpc_id
  load_balancer_arn            = module.sftp_nlb.load_balancer_arn
  load_balancer_security_group = module.sftp_nlb.security_group
  port                         = 2222
  protocol                     = "TCP"
  target_port                  = 22
  target_protocol              = "TCP"
  target_ips = var.sftp_server_ips
  security_group = {
    ingress = merge(
      {for k, v in var.allowed_cidr : k => { cidr = v }},
      {for k, v in var.allowed_security_group : k => { security_group = v }}
    )
  }
}
