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
variable "vpc_id" {
  description = "VPC ID where the AD Connector will be created"
  type        = string
}
variable "subnet_id" {
  type = string
}

variable "key_pair" {
  type     = string
  default  = null
  nullable = true
}
variable "ami" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "kms_key_arn" {
  type = string
}
variable "allowed_cidr" {
  type = object({
    all_traffic = optional(map(string), {})
    ssh = optional(map(string), {})
  })
  default = {}
}
variable "allowed_security_group" {
  type = object({
    all_traffic = optional(map(string), {})
    ssh = optional(map(string), {})
  })
  default = {}
}
variable "buckets" {
  type = map(object({
    arn = string
    prefix = optional(string, "/")
    kms_key_arn = optional(string)
  }))
}
variable "queues" {
  type = map(object({
    arn = string
    kms_key_arn = optional(string)
  }))
}
variable "secrets" {
  type = object({
    interchange_database = object({
      arn = string
      kms_key_arn = optional(string)
    })
  })
}
variable "lambda" {
  type = object({
    send_mail = object({
      arn = string
    })
  })
}

variable "devops" {
  type = object({
    artifact_bucket = object({
      arn = string
      prefix = optional(string, "/")
      kms_key_arn = optional(string)
    })
  })
  nullable = true
  default  = null
}