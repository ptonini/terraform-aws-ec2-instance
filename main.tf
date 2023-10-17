locals {
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
  source        = "ptonini/security-group/aws"
  version       = "~> 3.0.0"
  count         = var.security_group == null ? 0 : 1
  name          = "ec2-${var.name}"
  vpc           = var.security_group.vpc
  ingress_rules = var.security_group.ingress_rules
  egress_rules  = var.security_group.egress_rules
}

module "role" {
  source  = "ptonini/iam-role/aws"
  version = "~> 3.0.0"
  count   = var.instance_role == null ? 0 : 1
  name    = "ec2-${var.name}"
  assume_role_policy_statements = concat([{
    Effect = "Allow"
    Principal = {
      Service = "ec2.amazonaws.com"
    }
    Action = "sts:AssumeRole"
  }], var.instance_role.assume_role_policy_statements)
  policy_arns = var.instance_role.policy_arns
}

resource "aws_iam_instance_profile" "this" {
  count = var.instance_role == null ? 0 : 1
  role  = module.role[0].this.name
  lifecycle {
    ignore_changes = [
      tags,
      tags_all
    ]
  }
}

resource "aws_instance" "this" {
  count                  = var.host_count
  ami                    = var.ami
  ebs_optimized          = var.ebs_optimized
  instance_type          = var.type
  monitoring             = var.monitoring
  key_name               = var.key_name
  subnet_id              = element(var.subnets, (length(var.subnets) + count.index) % length(var.subnets)).id
  iam_instance_profile   = var.instance_role == null ? null : aws_iam_instance_profile.this[0].id
  vpc_security_group_ids = var.security_group == null ? var.vpc_security_group_ids : concat([module.security_group[0].this.id], var.vpc_security_group_ids)
  source_dest_check      = var.source_dest_check
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
      root_block_device[0].tags
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

