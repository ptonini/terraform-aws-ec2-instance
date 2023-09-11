locals {
  subnet_count = length(var.subnets)
  volumes = { for disk in flatten([
    for i in range(var.host_count) : [
      for k, v in var.volumes : {
        fullname    = "${k}-${i}"
        host_index  = i
        device_name = v.device_name
        size        = v.size
      }
    ]
  ]) : disk.fullname => disk }
}


module "security_group" {
  source                = "ptonini/security-group/aws"
  version               = "~> 1.0.0"
  vpc                   = var.vpc
  ingress_rules         = var.ingress_rules
  builtin_ingress_rules = var.builtin_ingress_rules
  egress_rules          = var.egress_rules
  builtin_egress_rules  = var.builtin_egress_rules
  providers = {
    aws = aws
  }
}

module "role" {
  source  = "ptonini/iam-role/aws"
  version = "~> 2.0.0"
  count   = var.instance_role ? 1 : 0
  assume_role_policy_statements = concat(
    [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }],
    var.instance_assume_role_policy_statements
  )
  policy_arns = var.instance_policy_arns
  providers = {
    aws = aws
  }
}

resource "aws_iam_instance_profile" "this" {
  count = var.instance_role ? 1 : 0
  role  = module.role[0].this.name
  lifecycle {
    ignore_changes = [
      tags,
      tags_all
    ]
  }
}

resource "aws_instance" "this" {
  count                = var.host_count
  ami                  = var.ami
  ebs_optimized        = var.ebs_optimized
  instance_type        = var.type
  monitoring           = var.monitoring
  key_name             = var.key_name
  subnet_id            = element(var.subnets, (length(var.subnets) + count.index) % local.subnet_count).id
  iam_instance_profile = var.instance_role ? aws_iam_instance_profile.this[0].id : null
  vpc_security_group_ids = [
    module.security_group.this.id
  ]
  source_dest_check = var.source_dest_check
  root_block_device {
    volume_type           = var.root_volume.volume_type
    volume_size           = var.root_volume.volume_size
    delete_on_termination = var.root_volume.delete_on_termination
  }
  tags = merge({ Name = "${var.name}${format("%04.0f", count.index + 1)}" }, var.tags)
  lifecycle {
    ignore_changes = [
      tags,
      tags_all,
      root_block_device[0]["tags"]
    ]
  }
}

resource "aws_ebs_volume" "this" {
  for_each          = local.volumes
  availability_zone = aws_instance.this[each.value["host_index"]].availability_zone
  size              = each.value["size"]
  lifecycle {
    ignore_changes = [
      tags,
      tags_all
    ]
  }
}

resource "aws_volume_attachment" "this" {
  for_each    = local.volumes
  device_name = each.value["device_name"]
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = aws_instance.this[each.value["host_index"]].id
}

resource "aws_eip" "this" {
  count    = var.fixed_public_ip ? var.host_count : 0
  instance = aws_instance.this[count.index].id
  lifecycle {
    ignore_changes = [
      tags,
      tags_all
    ]
  }
}

