# Installation

> Configuration: voir `.env` pour IPs/ports

## Prérequis

- Terraform >= 1.5.0
- Ansible >= 2.9
- Proxmox VE 7+ avec token API

## Étapes

### 1. Préparation

```bash
# Dépendances
apt install terraform ansible

# Cloner le projet
git clone <repo>
cd Monitoring
```

### 2. Configuration

```bash
# Variables d'environnement
cp scripts/.env.example .env
nano .env

# Terraform
cd terraform/env/dev
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

### 3. Déploiement

```bash
# Terraform
terraform init
terraform apply

# Ansible
cd ../..
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/deploy-prometheus.yml
```

Ou simplement: `make quick-deploy`

## Accès

| Service | URL | Login |
|---------|-----|-------|
| Prometheus | http://$PROMETHEUS_IP:9090 | - |
| Kibana | http://$ELK_IP:5601 | admin/admin |
| Grafana | http://$GRAFANA_IP:3000 | admin/admin |
| Zabbix | http://$ZABBIX_IP:8080 | Admin/zabbix |

## SSH

```bash
make ssh-config
ssh monitoring-prometheus
```
