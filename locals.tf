locals {
  subnet_count = length(var.subnets)
  volumes = {for disk in flatten([
    for i in range(var.host_count) : [
      for k, v in var.volumes : {
        fullname = "${k}-${i}"
        host_index = i
        device_name = v.device_name
        size = v.size
      }
    ]
  ]) : disk.fullname => disk}
}
