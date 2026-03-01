# Alertes

## Zabbix

### Configuration

1. **Médias**: Administration → Media types → Email/Slack
2. **Triggers**: Configuration → Triggers
3. **Actions**: Configuration → Actions

### Exemples de triggers

```yaml
# CPU
avg(/Linux CPU/system.cpu.util,5m) > 80

# Mémoire
last(/Linux Memory/memory.available) < 1GB

# Disque
last(/Linux Disk/vfs.fs.size[/,pused]) > 90
```

## Prometheus Alertmanager

Configuration: `/etc/alertmanager/alertmanager.yml`

```yaml
route:
  receiver: 'email'
receivers:
  - name: 'email'
    email_configs:
      - to: 'admin@example.com'
```

### Règles d'alertes

```yaml
groups:
- name: alerts
  rules:
    - alert: HighCPU
      expr: cpu > 80
      for: 5m
```

## Vérification

```bash
# Zabbix
zabbix_get -s $PROMETHEUS_IP -k system.cpu.load[all,avg5]

# Prometheus
curl http://$PROMETHEUS_IP:9093/api/v1/alerts
```
