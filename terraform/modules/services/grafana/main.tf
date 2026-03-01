# Grafana Service Module

variable "grafana_ip" {
  description = "Grafana server IP"
  type        = string
}

variable "grafana_port" {
  description = "Grafana port"
  type        = number
  default     = 3000
}

variable "admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "prometheus_url" {
  description = "Prometheus datasource URL"
  type        = string
  default     = ""
}

variable "elasticsearch_url" {
  description = "Elasticsearch datasource URL"
  type        = string
  default     = ""
}

variable "zabbix_url" {
  description = "Zabbix datasource URL"
  type        = string
  default     = ""
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "http://${var.grafana_ip}:${var.grafana_port}"
}

output "grafana_admin_url" {
  description = "Grafana admin URL"
  value       = "http://${var.grafana_ip}:${var.grafana_port}/admin"
}

output "grafana_ip" {
  description = "Grafana server IP"
  value       = var.grafana_ip
}

output "grafana_port" {
  description = "Grafana port"
  value       = var.grafana_port
}

output "grafana_datasources" {
  description = "Grafana datasources configuration"
  value = {
    prometheus    = var.prometheus_url
    elasticsearch = var.elasticsearch_url
    zabbix        = var.zabbix_url
  }
}
