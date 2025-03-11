module "key" {
  # source = "../../../../modules/intelica-module-kms/customer-key"
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-kms//customer-key"

  name                 = var.name
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  decrypt_only_account_ids = var.kms_key_decrypt_only_account_ids
}