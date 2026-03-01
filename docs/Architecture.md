# Architecture

> IPs/ports configurables via `.env` (voir `scripts/.env.example`)

## Composants

| VM | IP (défaut) | CPU | RAM | Disque | Services |
|----|-------------|-----|-----|--------|----------|
| Prometheus | 192.168.1.110 | 4 | 8GB | 64GB | Prometheus, Node Exporter |
| ELK | 192.168.1.111 | 4 | 16GB | 128GB | Elasticsearch, Kibana, Logstash |
| Grafana | 192.168.1.112 | 2 | 4GB | 32GB | Grafana |
| Zabbix | 192.168.1.113 | 4 | 8GB | 64GB | Zabbix, MariaDB, Apache |

**Total**: 14 CPU, 36 GB RAM, ~300 GB

## Flux

```
Services → Node Exporter → Prometheus → Grafana (dashboards)
                     ↓                   
              Alertmanager → Notifications

Applications → Filebeat → Logstash → Elasticsearch → Kibana
```

## Réseau

- Réseau: `192.168.1.0/24` (configurable)
- Accès: restriction via UFW vers `MONITORING_NETWORK`

## Connexions

| Source → Destination | Port |
|---------------------|------|
| Grafana → Prometheus | 9090 |
| Grafana → Elasticsearch | 9200 |
| Prometheus → Node Exporter | 9100 |
| Filebeat → Logstash | 5044 |
