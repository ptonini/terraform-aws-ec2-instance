variable "name" {}

variable "account" {}

variable "host_count" {
  default = 1
}

variable "ami" {}

variable "type" {
  default = "t3a.micro"
}

variable "key_name" {}

variable "vpc" {
  type = object({
    id = string
  })
}

variable "subnets" {
  type = list(object({
    id = string
  }))
}

variable "root_volume" {
  default = {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }
}

variable "tags" {}

variable "source_dest_check" {
  default = "true"
}

variable "ingress_rules" {
  default = {}
}

variable "builtin_ingress_rules" {
  default = []
}

variable "egress_rules" {
  default = {}
}

variable "builtin_egress_rules" {
  default = ["all"]
}

variable "instance_role" {
  default = false
}

variable "instance_assume_role_policy_statements" {
  default = []
}

variable "instance_policy_arns" {
  default = {}
}

variable "fixed_public_ip" {
  default = false
}

variable "volumes" {
  type = map(object({
    size        = number
    device_name = string
  }))
  default = {}
}