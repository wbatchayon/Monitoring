# Dev environment main configuration
# Creates 4 VMs for the monitoring stack

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.71.0"
    }
  }
}

# Proxmox provider configuration
provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = true

  ssh {
    agent    = false
    username = var.proxmox_ssh_user != "" ? var.proxmox_ssh_user : null
    password = var.proxmox_ssh_password != "" ? var.proxmox_ssh_password : null
  }
}

# Build full IP addresses from network + octet
locals {
  prometheus_full_ip = "${var.monitoring_network}.${var.prometheus_ip}"
  elk_full_ip       = "${var.monitoring_network}.${var.elk_ip}"
  grafana_full_ip   = "${var.monitoring_network}.${var.grafana_ip}"
  zabbix_full_ip    = "${var.monitoring_network}.${var.zabbix_ip}"
}

# VM 110 - Prometheus
module "vm_prometheus" {
  source = "../../modules/vm"

  name            = "monitoring-prometheus"
  vmid            = var.proxmox_vm_id + 10
  ip_address      = local.prometheus_full_ip
  cores           = 2
  memory          = 4096
  disk_size       = "20G"
  service_type    = "prometheus"
  proxmox_node    = var.proxmox_node
  proxmox_storage = var.proxmox_storage
  network_bridge  = var.network_bridge
  gateway         = var.gateway
  dns_servers     = var.dns_servers
  ssh_public_key  = file(var.ssh_public_key_path)
  vm_password     = var.vm_password
}

# VM 111 - ELK Stack
module "vm_elk" {
  source = "../../modules/vm"

  name            = "monitoring-elk"
  vmid            = var.proxmox_vm_id + 11
  ip_address      = local.elk_full_ip
  cores           = 4
  memory          = 8192
  disk_size       = "50G"
  service_type    = "elk"
  proxmox_node    = var.proxmox_node
  proxmox_storage = var.proxmox_storage
  network_bridge  = var.network_bridge
  gateway         = var.gateway
  dns_servers     = var.dns_servers
  ssh_public_key  = file(var.ssh_public_key_path)
  vm_password     = var.vm_password
}

# VM 112 - Grafana
module "vm_grafana" {
  source = "../../modules/vm"

  name            = "monitoring-grafana"
  vmid            = var.proxmox_vm_id + 12
  ip_address      = local.grafana_full_ip
  cores           = 2
  memory          = 4096
  disk_size       = "20G"
  service_type    = "grafana"
  proxmox_node    = var.proxmox_node
  proxmox_storage = var.proxmox_storage
  network_bridge  = var.network_bridge
  gateway         = var.gateway
  dns_servers     = var.dns_servers
  ssh_public_key  = file(var.ssh_public_key_path)
  vm_password     = var.vm_password
}

# VM 113 - Zabbix
module "vm_zabbix" {
  source = "../../modules/vm"

  name            = "monitoring-zabbix"
  vmid            = var.proxmox_vm_id + 13
  ip_address      = local.zabbix_full_ip
  cores           = 2
  memory          = 4096
  disk_size       = "20G"
  service_type    = "zabbix"
  proxmox_node    = var.proxmox_node
  proxmox_storage = var.proxmox_storage
  network_bridge  = var.network_bridge
  gateway         = var.gateway
  dns_servers     = var.dns_servers
  ssh_public_key  = file(var.ssh_public_key_path)
  vm_password     = var.vm_password
}

# Service Configuration Modules
module "prometheus_service" {
  source = "../../modules/services/prometheus"

  prometheus_ip   = module.vm_prometheus.ip_address
  prometheus_port = var.prometheus_port
  retention       = "15d"
  scrape_interval = "15s"
}

module "elk_service" {
  source = "../../modules/services/elk"

  elk_ip                  = module.vm_elk.ip_address
  elasticsearch_port      = var.elasticsearch_port
  kibana_port             = var.kibana_port
  logstash_port           = var.logstash_port
  elasticsearch_heap_size = 2
  logstash_heap_size      = 1
  retention_days          = 7
}

module "grafana_service" {
  source = "../../modules/services/grafana"

  grafana_ip        = module.vm_grafana.ip_address
  grafana_port      = var.grafana_port
  admin_user        = "admin"
  prometheus_url    = "http://${module.vm_prometheus.ip_address}:${var.prometheus_port}"
  elasticsearch_url = "http://${module.vm_elk.ip_address}:${var.elasticsearch_port}"
  zabbix_url        = "http://${module.vm_zabbix.ip_address}:${var.zabbix_port}"
}

module "zabbix_service" {
  source = "../../modules/services/zabbix"

  zabbix_ip         = module.vm_zabbix.ip_address
  zabbix_port       = var.zabbix_port
  zabbix_agent_port = var.zabbix_agent_port
}
