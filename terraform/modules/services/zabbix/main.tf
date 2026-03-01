# Zabbix Service Module

variable "zabbix_ip" {
  description = "Zabbix server IP"
  type        = string
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

variable "db_host" {
  description = "Database host"
  type        = string
  default     = "localhost"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "zabbix"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "zabbix"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "alert_email" {
  description = "Alert email address"
  type        = string
  default     = ""
}

variable "prometheus_ip" {
  description = "Prometheus IP for metrics"
  type        = string
  default     = ""
}

output "zabbix_url" {
  description = "Zabbix web interface URL"
  value       = "http://${var.zabbix_ip}:${var.zabbix_port}"
}

output "zabbix_api_url" {
  description = "Zabbix API endpoint"
  value       = "http://${var.zabbix_ip}:${var.zabbix_port}/api_jsonrpc.php"
}

output "zabbix_agent_endpoint" {
  description = "Zabbix agent endpoint"
  value       = "${var.zabbix_ip}:${var.zabbix_agent_port}"
}

output "zabbix_ip" {
  description = "Zabbix server IP"
  value       = var.zabbix_ip
}

output "zabbix_port" {
  description = "Zabbix web port"
  value       = var.zabbix_port
}

output "zabbix_agent_port" {
  description = "Zabbix agent port"
  value       = var.zabbix_agent_port
}
