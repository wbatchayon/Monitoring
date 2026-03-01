# Staging Environment Outputs

# Prometheus VM Outputs
output "prometheus_vm_id" {
  description = "Prometheus VM ID"
  value       = module.vm_prometheus.vm_id
}

output "prometheus_ip" {
  description = "Prometheus VM IP address"
  value       = module.vm_prometheus.ip_address
}

output "prometheus_url" {
  description = "Prometheus service URL"
  value       = module.prometheus_service.prometheus_url
}

# ELK VM Outputs
output "elk_vm_id" {
  description = "ELK VM ID"
  value       = module.vm_elk.vm_id
}

output "elk_ip" {
  description = "ELK VM IP address"
  value       = module.vm_elk.ip_address
}

output "elasticsearch_url" {
  description = "Elasticsearch URL"
  value       = module.elk_service.elasticsearch_url
}

output "kibana_url" {
  description = "Kibana URL"
  value       = module.elk_service.kibana_url
}

# Grafana VM Outputs
output "grafana_vm_id" {
  description = "Grafana VM ID"
  value       = module.vm_grafana.vm_id
}

output "grafana_ip" {
  description = "Grafana VM IP address"
  value       = module.vm_grafana.ip_address
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = module.grafana_service.grafana_url
}

# Zabbix VM Outputs
output "zabbix_vm_id" {
  description = "Zabbix VM ID"
  value       = module.vm_zabbix.vm_id
}

output "zabbix_ip" {
  description = "Zabbix VM IP address"
  value       = module.vm_zabbix.ip_address
}

output "zabbix_url" {
  description = "Zabbix web interface URL"
  value       = module.zabbix_service.zabbix_url
}

# All Monitoring VMs
output "monitoring_vms" {
  description = "All monitoring VMs information"
  value = {
    prometheus = {
      vm_id = module.vm_prometheus.vm_id
      ip    = module.vm_prometheus.ip_address
      url   = module.prometheus_service.prometheus_url
    }
    elk = {
      vm_id            = module.vm_elk.vm_id
      ip               = module.vm_elk.ip_address
      elasticsearch_url = module.elk_service.elasticsearch_url
      kibana_url       = module.elk_service.kibana_url
    }
    grafana = {
      vm_id = module.vm_grafana.vm_id
      ip    = module.vm_grafana.ip_address
      url   = module.grafana_service.grafana_url
    }
    zabbix = {
      vm_id = module.vm_zabbix.vm_id
      ip    = module.vm_zabbix.ip_address
      url   = module.zabbix_service.zabbix_url
    }
  }
}

# Service endpoints summary
output "service_endpoints" {
  description = "Summary of all service endpoints"
  value = {
    prometheus   = module.prometheus_service.prometheus_url
    elasticsearch = module.elk_service.elasticsearch_url
    kibana       = module.elk_service.kibana_url
    grafana      = module.grafana_service.grafana_url
    zabbix       = module.zabbix_service.zabbix_url
  }
}
