# Guide Monitoring

> IPs/ports configurables via `.env`

## Grafana

1. Connexion: `http://$GRAFANA_IP:3000` (admin/admin)
2. Ajouter datasource Prometheus: URL `http://$PROMETHEUS_IP:9090`
3. Ajouter datasource Elasticsearch: URL `http://$ELK_IP:9200`

Dashboards recommandés (ID Grafana):
- Node Exporter Full: #1860
- Prometheus Overview: #3662

## Prometheus

URL: `http://$PROMETHEUS_IP:9090`

Requêtes utiles:
```promql
# CPU
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Mémoire
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Disque
100 - (node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100
```

## Kibana

URL: `http://$ELK_IP:5601`

Créer index pattern: `filebeat-*`

## Zabbix

URL: `http://$ZABBIX_IP:8080` (Admin/zabbix)

Configuration:
1. Hosts → Create Host
2. Link template: Linux by Zabbix agent
3. Interfaces: Agent IP, port 10050

## Vérification

```bash
curl http://$PROMETHEUS_IP:9090/api/v1/query?query=up
curl http://$ELK_IP:9200/_cluster/health
make status
```
