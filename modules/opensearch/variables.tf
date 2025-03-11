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
variable "name" {
  type     = string
  nullable = true
  default  = null
}
variable "engine_version" {
  type    = string
  default = "OpenSearch_2.3"
}
variable "instance_type" {
  type    = string
  default = "t3.small.search"
}
variable "kms_key_arn" {
  type = string
}
variable "storage_size" {
  type    = number
  default = 100
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "secret_read_only_account_ids" {
  type = list(string)
  default = []
}