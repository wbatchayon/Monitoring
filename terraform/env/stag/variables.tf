# Staging environment variables

variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_ssh_user" {
  description = "SSH username for Proxmox connection"
  type        = string
  default     = "root"
}

variable "proxmox_ssh_password" {
  description = "SSH password for Proxmox connection"
  type        = string
  sensitive   = true
  default     = ""
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

variable "proxmox_vm_id" {
  description = "Base VM ID for Proxmox"
  type        = number
  default     = 7000
}

variable "network_bridge" {
  description = "Network bridge for VMs"
  type        = string
  default     = "vmbr0"
}

variable "gateway" {
  description = "Default gateway for VMs"
  type        = string
  default     = "192.168.1.1"
}

variable "dns_servers" {
  description = "DNS servers for VMs"
  type        = list(string)
  default     = ["192.168.1.1", "1.1.1.1"]
}

# Network configuration
variable "monitoring_network" {
  description = "Monitoring network base (e.g., 192.168.1)"
  type        = string
  default     = "192.168.1"
}

# Service IPs (last octet)
variable "prometheus_ip" {
  description = "Prometheus service IP (last octet)"
  type        = string
  default     = "30"
}

variable "elk_ip" {
  description = "ELK service IP (last octet)"
  type        = string
  default     = "31"
}

variable "grafana_ip" {
  description = "Grafana service IP (last octet)"
  type        = string
  default     = "32"
}

variable "zabbix_ip" {
  description = "Zabbix service IP (last octet)"
  type        = string
  default     = "33"
}

# Service ports
variable "prometheus_port" {
  description = "Prometheus web port"
  type        = number
  default     = 9090
}

variable "elasticsearch_port" {
  description = "Elasticsearch port"
  type        = number
  default     = 9200
}

variable "kibana_port" {
  description = "Kibana port"
  type        = number
  default     = 5601
}

variable "logstash_port" {
  description = "Logstash port"
  type        = number
  default     = 5044
}

variable "grafana_port" {
  description = "Grafana port"
  type        = number
  default     = 3000
}

variable "zabbix_port" {
  description = "Zabbix web port"
  type        = number
  default     = 8080
}

variable "zabbix_agent_port" {
  description = "Zabbix agent port"
  type        = number
  default     = 10050
}

# SSH configuration
variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "ssh_username" {
  description = "SSH username"
  type        = string
  default     = "ubuntu"
}

variable "vm_password" {
  description = "VM password for cloud-init"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.vm_password) >= 8
    error_message = "Password must be at least 8 characters long."
  }
}

# Security variables
variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access SSH"
  type        = string
  default     = "192.168.1.0/24"
}

variable "enable_firewall" {
  description = "Enable UFW firewall on VMs"
  type        = bool
  default     = true
}

variable "enable_fail2ban" {
  description = "Enable fail2ban on VMs"
  type        = bool
  default     = true
}

variable "enable_auto_updates" {
  description = "Enable automatic security updates"
  type        = bool
  default     = true
}
