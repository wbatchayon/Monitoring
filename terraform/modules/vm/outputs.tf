# VM Module Outputs

output "vm_id" {
  description = "Proxmox VM ID"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "name" {
  description = "VM name"
  value       = proxmox_virtual_environment_vm.vm.name
}

output "ip_address" {
  description = "VM IP address"
  value       = var.ip_address
}

output "service_type" {
  description = "Service type"
  value       = var.service_type
}

output "tags" {
  description = "VM tags"
  value       = var.tags
}

output "cpu_cores" {
  description = "Number of CPU cores"
  value       = var.cores
}

output "memory_mb" {
  description = "Memory in MB"
  value       = var.memory
}

output "disk_size" {
  description = "Disk size"
  value       = var.disk_size
}
