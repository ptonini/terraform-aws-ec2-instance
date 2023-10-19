variable "name" {}

variable "host_count" {
  default = 1
}

variable "ami" {}

variable "type" {
  default = "t3a.micro"
}

variable "key_name" {}

variable "subnets" {
  type = list(object({
    id = string
  }))
}

variable "root_volume" {
  type = object({
    volume_type           = optional(string, "gp2")
    volume_size           = optional(number, 20)
    delete_on_termination = optional(bool, true)
  })
  default = {}
}

variable "source_dest_check" {
  default = true
}

variable "ebs_optimized" {
  default = true
}

variable "monitoring" {
  default = false
}

variable "instance_role" {
  type = object({
    enabled                       = optional(bool, true)
    assume_role_policy_statements = optional(list(any), [])
    policy_arns                   = optional(set(string))
  })
  default = null
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

variable "security_group" {
  type = object({
    enabled = optional(bool, true)
    vpc = optional(object({
      id = string
    }))
    ingress_rules = optional(map(object({
      from_port                    = optional(number)
      to_port                      = optional(number)
      ip_protocol                  = optional(string, "tcp")
      cidr_ipv4                    = optional(string)
      cidr_ipv6                    = optional(string)
      prefix_list_id               = optional(string)
      referenced_security_group_id = optional(string)
    })), { self = { ip_protocol = -1, referenced_security_group_id = "self" } })
    egress_rules = optional(map(object({
      from_port                    = optional(number)
      to_port                      = optional(number)
      ip_protocol                  = optional(string, "tcp")
      cidr_ipv4                    = optional(string)
      cidr_ipv6                    = optional(string)
      prefix_list_id               = optional(string)
      referenced_security_group_id = optional(string)
    })), { all = { ip_protocol = -1, cidr_ipv4 = "0.0.0.0/0" } })
  })
  default = null
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  default = {}
}

