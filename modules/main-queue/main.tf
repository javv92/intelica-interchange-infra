locals {

}

module "btro" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-sqs//queue"

  name                 = "${var.name}-btro"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.kms_key_arn
  fifo                 = false
}


module "cndo" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-sqs//queue"

  name                 = "${var.name}-cndo"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.kms_key_arn
  fifo                 = false
}
module "ebgr" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-sqs//queue"

  name                 = "${var.name}-ebgr"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.kms_key_arn
  fifo                 = false
}
module "fihn" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-sqs//queue"

  name                 = "${var.name}-fihn"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.kms_key_arn
  fifo                 = false
}
module "fope" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-sqs//queue"

  name                 = "${var.name}-fope"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.kms_key_arn
  fifo                 = false
}
module "gnmx" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-sqs//queue"

  name                 = "${var.name}-gnmx"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.kms_key_arn
  fifo                 = false
}
module "inpe" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-sqs//queue"

  name                 = "${var.name}-inpe"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.kms_key_arn
  fifo                 = false
}
module "sbpe" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-sqs//queue"

  name                 = "${var.name}-sbpe"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.kms_key_arn
  fifo                 = false
}
module "sbsa" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-sqs//queue"

  name                 = "${var.name}-sbsa"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.kms_key_arn
  fifo                 = false
}
module "ucit" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-sqs//queue"

  name                 = "${var.name}-ucit"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.kms_key_arn
  fifo                 = false
}
module "upn" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-sqs//queue"

  name                 = "${var.name}-ucit"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.kms_key_arn
  fifo                 = false
}