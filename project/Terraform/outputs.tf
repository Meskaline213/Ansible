output "vm_ips" {
  value = concat(
    [yandex_compute_instance.vm1.network_interface[0].nat_ip_address],
    [for vm in yandex_compute_instance.vms : vm.network_interface[0].nat_ip_address]
  )
}
