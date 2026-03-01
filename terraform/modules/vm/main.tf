# VM Module
# This module creates a VM on Proxmox with the specified configuration

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.71.0"
    }
  }
}

# Create the VM using the new Proxmox provider API
resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.name
  vm_id     = var.vmid
  node_name = var.proxmox_node

  # Clone from template
  clone {
    vm_id = 9000  # Template VM ID - adjust as needed
    full  = true
  }

  # CPU Configuration
  cpu {
    cores   = var.cores
    sockets = 1
    type    = "host"
  }

  # Memory Configuration
  memory {
    dedicated = var.memory
  }

  # Network Configuration
  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  # Disk Configuration - Root disk (scsi0)
  # Note: Cloud-init disk (ide2) is automatically included when cloning from template
  disk {
    datastore_id = var.proxmox_storage
    interface    = "scsi0"
    size         = 20
    iothread     = true
  }

  # Initialization
  initialization {
    datastore_id = var.proxmox_storage
    
    ip_config {
      ipv4 {
        address = "${var.ip_address}/24"
        gateway = var.gateway
      }
    }

    user_account {
      username = "ubuntu"
      password = var.vm_password
      keys     = [var.ssh_public_key]
    }
  }

  # Agent
  agent {
    enabled = true
  }

  # OS Type
  operating_system {
    type = "l26"
  }
}
