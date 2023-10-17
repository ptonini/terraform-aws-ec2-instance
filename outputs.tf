output "this" {
  value = aws_instance.this
}

output "public_ips" {
  value = aws_eip.this
}

output "security_group_id" {
  value = var.security_group == null ? null : module.security_group[0].this.id
}