output "nics" {
  description = "Export objects of NICs."
  value       = length(var.nics) != 0 ? values(azurerm_network_interface.nics)[*] : null
}

output "vm_identity" {
  description = "Identity used by VM."
  sensitive   = true
  value       = azurerm_linux_virtual_machine.main.identity
}

output "vm_private_ips" {
  description = "List of Private IP addresses associated with VM"
  value       = azurerm_linux_virtual_machine.main.private_ip_addresses
}

output "vm_network_interface_ids" {
  description = "List of NIC IDs."
  sensitive   = true
  value       = values(azurerm_network_interface.nics)[*].id
}

output "vm_id" {
  description = "Virtual Machine ID"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm" {
  description = "Export of full vm object."
  value       = azurerm_linux_virtual_machine.main
}

output "data_disk_ids" {
  description = "List of Data Disk IDs"
  value       = values(azurerm_managed_disk.disks_data)[*].id
}

output "os_disk_name" {
  description = "OS Disk Name"
  value       = azurerm_linux_virtual_machine.main.os_disk[0].name # azurerm_virtual_machine.main.storage_os_disk[1]
}