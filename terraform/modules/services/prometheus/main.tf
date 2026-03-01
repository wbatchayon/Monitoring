# Prometheus Service Module
# This module defines outputs for Prometheus service configuration

variable "prometheus_ip" {
  description = "Prometheus server IP"
  type        = string
}

variable "prometheus_port" {
  description = "Prometheus port"
  type        = number
  default     = 9090
}

variable "retention" {
  description = "Data retention period"
  type        = string
  default     = "15d"
}

variable "scrape_interval" {
  description = "Scrape interval"
  type        = string
  default     = "15s"
}

variable "alert_targets" {
  description = "Alert target IPs"
  type        = list(string)
  default     = []
}

# Outputs for service URLs
output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${var.prometheus_ip}:${var.prometheus_port}"
}

output "prometheus_api_url" {
  description = "Prometheus API endpoint"
  value       = "http://${var.prometheus_ip}:${var.prometheus_port}/api/v1"
}

output "prometheus_ip" {
  description = "Prometheus server IP"
  value       = var.prometheus_ip
}

output "prometheus_port" {
  description = "Prometheus port"
  value       = var.prometheus_port
}

output "retention_period" {
  description = "Data retention period"
  value       = var.retention
}

output "scrape_interval" {
  description = "Metrics scrape interval"
  value       = var.scrape_interval
}
