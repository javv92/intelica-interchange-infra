variable "global_tags" {
  type = map(string)
  default = {}
}

variable "stack_number" {
  description = "Use to avoid conflicts when deploying various instances of this instance with the same name."
  type        = string
  default     = "00"

  validation {
    condition = can(regex("^[0-9]{2}$", var.stack_number))
    error_message = "Stack Number solo permite valores de 00 al 99."
  }
}

variable "prefix_resource_name" {
  description = "Required - the prefix name is used to name the resources {coid}-{assetid}-{appid} or applying-000-terraform"
  type        = string
  default     = "aply-0001-gen-all"

  validation {
    condition = can(regex("^[a-z0-9-]+$", var.prefix_resource_name))
    error_message = "The prefix_resource_name value must be lowercase!"
  }
}
variable "vpc_id" {
  description = "VPC ID where the DB cluster will be deployed"
  type        = string
}
variable "public_subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type = list(string)
}
variable "private_subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type = list(string)
}
variable "restricted_subnet_ids" {
  type = list(string)
}
variable "sftp" {
  type = object({
    subnet = string
    certificate_arn = optional(string, null)
    custom_host_name = optional(string, null)
    hosted_zone_id = optional(string, null)
    allowed_cidr = optional(map(string), {})
    allowed_security_group = optional(map(string), {})
  })
}
variable "sftp_nlb" {
  type = object({
    certificate_arn = optional(string, null)
    custom_host_name = optional(string, null)
    hosted_zone_id = optional(string, null)
    allowed_cidr = optional(map(string), {})
    allowed_security_group = optional(map(string), {})
  })
}
variable "database" {
  type = object({
    snapshot_identifier = string
    allowed_cidr = optional(map(string), {})
    allowed_security_group = optional(map(string), {})
  })
}
variable "instance" {
  type = object({
    ami           = string
    instance_type = string
    key_pair = optional(string, null)
    allowed_cidr = optional(object({
      all_traffic = optional(map(string), {})
      ssh = optional(map(string), {})
    }), {})
    allowed_security_group = optional(object({
      all_traffic = optional(map(string), {})
      ssh = optional(map(string), {})
    }), {})
  })
}
variable "opensearch" {
  type = object({
    engine_version = optional(string, "OpenSearch_2.3")
    instance_type = optional(string, "t3.small.search")
    storage_size = optional(number, 100)
    instance_count = optional(number, 1)
  })
}