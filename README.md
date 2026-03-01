# Monitoring Infrastructure

Infrastructure de monitoring pour Proxmox avec Terraform + Ansible.

> **Config**: Toutes les IPs/ports sont configurables via `.env` (voir `scripts/.env.example`)

## Services

| VM | Service | Port | Rôle |
|----|---------|------|------|
| +10 | Prometheus | 9090 | Métriques |
| +11 | ELK | 9200/5601 | Logs |
| +12 | Grafana | 3000 | Dashboards |
| +13 | Zabbix | 8080 | Alertes |

## Déploiement

```bash
# Configuration
cp scripts/.env.example .env && nano .env

# Déploiement
source .env
make apply
make deploy-all
```

## Accès

| Service | URL | Identifiants |
|---------|-----|--------------|
| Prometheus | http://$PROMETHEUS_IP:$PROMETHEUS_PORT | - |
| Kibana | http://$ELK_IP:$KIBANA_PORT | admin/admin |
| Grafana | http://$GRAFANA_IP:$GRAFANA_PORT | admin/admin |
| Zabbix | http://$ZABBIX_IP:$ZABBIX_PORT | Admin/zabbix |

## Sécurité

- Pare-feu UFW: restriction réseau via `MONITORING_NETWORK`
- Fail2ban activé
- Mises à jour automatiques
- Secrets via Ansible Vault

Voir [SECURITY.md](SECURITY.md) pour la politique de sécurité.
