# Éléments Monitorés

## Métriques Système

| Métrique | Description | Seuil |
|----------|-------------|-------|
| up | Disponibilité | = 0 |
| cpu | CPU usage | > 80% |
| memory | Mémoire usage | > 90% |
| disk | Disque usage | > 85% |
| load | Charge système | > CPU cores |

## Services

| Service | Métriques |
|---------|-----------|
| Prometheus | tsdb, targets |
| Elasticsearch | cluster health, indices |
| Kibana | requests, sessions |
| Grafana | dashboards, datasources |
| Zabbix | processes, queue |

## Logs

Index: `filebeat-*`

Chemins:
- `/var/log/syslog`
- `/var/log/auth.log`
- `/var/log/nginx/*.log`

## Alertes

### Critical
- Host down
- Disk full (>95%)
- Service crash

### Warning
- High CPU (>80%)
- High Memory (>90%)
- Disk warning (>85%)

## Rétention

| Type | Durée |
|------|-------|
| Prometheus | 15 jours |
| Elasticsearch | 30 jours |
| Zabbix | 90 jours |
