# VM Module Variables

variable "name" {
  description = "Name of the VM"
  type        = string
}

variable "vmid" {
  description = "VM ID in Proxmox"
  type        = number
}

variable "ip_address" {
  description = "IP address for the VM"
  type        = string

  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.ip_address))
    error_message = "IP address must be a valid IPv4 address."
  }
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2

  validation {
    condition     = var.cores >= 1 && var.cores <= 64
    error_message = "CPU cores must be between 1 and 64."
  }
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048

  validation {
    condition     = var.memory >= 512 && var.memory <= 131072
    error_message = "Memory must be between 512 MB and 128 GB."
  }
}

variable "disk_size" {
  description = "Disk size (e.g., 20G)"
  type        = string
  default     = "20G"
}

variable "service_type" {
  description = "Type of service (prometheus, elk, grafana, zabbix)"
  type        = string

  validation {
    condition     = contains(["prometheus", "elk", "grafana", "zabbix"], var.service_type)
    error_message = "Service type must be one of: prometheus, elk, grafana, zabbix."
  }
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

variable "proxmox_storage" {
  description = "Storage for VMs"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "gateway" {
  description = "Default gateway"
  type        = string
  default     = "192.168.1.1"

  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.gateway))
    error_message = "Gateway must be a valid IPv4 address."
  }
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
  default     = ["192.168.1.1", "1.1.1.1"]
}

variable "domain" {
  description = "Domain name"
  type        = string
  default     = "local"
}

variable "ssh_public_key" {
  description = "SSH public key for access (REQUIRED)"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^ssh-rsa |^ssh-ed25519 |^ecdsa-", var.ssh_public_key))
    error_message = "SSH public key must be a valid SSH key format."
  }
}

variable "vm_password" {
  description = "VM password for cloud-init (REQUIRED)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.vm_password) >= 8
    error_message = "Password must be at least 8 characters long."
  }
}

variable "tags" {
  description = "Tags for the VM"
  type        = map(string)
  default     = {}
}
