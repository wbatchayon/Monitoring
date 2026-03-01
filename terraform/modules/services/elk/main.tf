# ELK Service Module
# This module defines outputs for ELK service configuration

variable "elk_ip" {
  description = "ELK server IP"
  type        = string
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

variable "elasticsearch_heap_size" {
  description = "Elasticsearch heap size (GB)"
  type        = number
  default     = 4
}

variable "logstash_heap_size" {
  description = "Logstash heap size (GB)"
  type        = number
  default     = 1
}

variable "retention_days" {
  description = "Log retention days"
  type        = number
  default     = 30
}

# Outputs for service URLs
output "elasticsearch_url" {
  description = "Elasticsearch URL"
  value       = "http://${var.elk_ip}:${var.elasticsearch_port}"
}

output "kibana_url" {
  description = "Kibana dashboard URL"
  value       = "http://${var.elk_ip}:${var.kibana_port}"
}

output "logstash_url" {
  description = "Logstash endpoint"
  value       = "${var.elk_ip}:${var.logstash_port}"
}

output "elasticsearch_port" {
  description = "Elasticsearch port"
  value       = var.elasticsearch_port
}

output "kibana_port" {
  description = "Kibana port"
  value       = var.kibana_port
}

output "logstash_port" {
  description = "Logstash port"
  value       = var.logstash_port
}
