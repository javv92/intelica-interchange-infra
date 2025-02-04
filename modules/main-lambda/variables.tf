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
  type = string
}

variable "sources" {
  type = object({
    buckets = map(object({
      arn = string
      prefix = optional(string, "/")
      kms_key_arn = optional(string)
    }))
  })
}
variable "targets" {
  type = object({
    queues = map(object({
      arn = string
      kms_key_arn = optional(string)
    }))
  })
}