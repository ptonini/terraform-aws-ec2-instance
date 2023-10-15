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
    assume_role_policy_statements = list(any)
    policy_arns                   = optional(set(string))
  })
  default = { enabled = false }
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
    vpc = object({
      id = string
    })
    ingress_rules = optional(map(object({
      from_port        = number
      to_port          = optional(number)
      protocol         = optional(string)
      cidr_blocks      = optional(set(string))
      ipv6_cidr_blocks = optional(set(string))
      prefix_list_ids  = optional(set(string))
      security_groups  = optional(set(string))
      self             = optional(bool)
    })), {})
    egress_rules = optional(map(object({
      from_port        = number
      to_port          = optional(number)
      protocol         = optional(string)
      cidr_blocks      = optional(set(string))
      ipv6_cidr_blocks = optional(set(string))
      prefix_list_ids  = optional(set(string))
      security_groups  = optional(set(string))
      self             = optional(bool)
    })), {})
  })
  default = { enabled = false }
}

variable "vpc_security_group_ids" {
  type    = set(string)
  default = []
}

variable "tags" {
  default = {}
}

