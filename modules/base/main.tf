module "key" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-kms//customer-key"

  name                 = var.name
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
}