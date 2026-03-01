# Makefile for Monitoring Infrastructure

.PHONY: help init plan apply destroy deploy-all deploy-prometheus deploy-elk deploy-grafana deploy-zabbix deploy-services-portal status check ssh-config

# Default values - override with environment variables
PROMETHEUS_IP ?= 192.168.1.110
ELK_IP ?= 192.168.1.111
GRAFANA_IP ?= 192.168.1.112
ZABBIX_IP ?= 192.168.1.113

PROMETHEUS_PORT ?= 9090
ELASTICSEARCH_PORT ?= 9200
KIBANA_PORT ?= 5601
GRAFANA_PORT ?= 3000
ZABBIX_PORT ?= 8080

# Colors
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m

help:
	@echo "$(BLUE)Monitoring Infrastructure - Proxmox Deployment$(NC)"
	@echo ""
	@echo "Environment variables:"
	@echo "  PROMETHEUS_IP, ELK_IP, GRAFANA_IP, ZABBIX_IP"
	@echo "  PROMETHEUS_PORT, ELASTICSEARCH_PORT, KIBANA_PORT, GRAFANA_PORT, ZABBIX_PORT"
	@echo ""
	@echo "Targets:"
	@echo "  make init, make plan, make apply, make destroy"
	@echo "  make deploy-all, make deploy-prometheus, make deploy-elk"
	@echo "  make deploy-grafana, make deploy-zabbix, make status, make ssh-config"

init:
	@echo "$(GREEN)Initializing Terraform...$(NC)"
	cd terraform/env/dev && terraform init

plan:
	@echo "$(GREEN)Planning Terraform...$(NC)"
	cd terraform/env/dev && terraform plan

apply:
	@echo "$(GREEN)Applying Terraform...$(NC)"
	cd terraform/env/dev && terraform apply

destroy:
	@echo "$(YELLOW)Destroying infrastructure...$(NC)"
	cd terraform/env/dev && terraform destroy

deploy-all:
	@echo "$(GREEN)Deploying monitoring stack...$(NC)"
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/deploy-prometheus.yml

deploy-prometheus:
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/deploy-prometheus-only.yml

deploy-elk:
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/deploy-elk-only.yml

deploy-grafana:
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/deploy-grafana-only.yml

deploy-zabbix:
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/deploy-zabbix-only.yml

deploy-services-portal:
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/deploy-services-portal.yml

status:
	@echo "Prometheus: $$(curl -s -o /dev/null -w '%{http_code}' http://$(PROMETHEUS_IP):$(PROMETHEUS_PORT) 2>/dev/null || echo 'DOWN')"
	@echo "Elasticsearch: $$(curl -s -o /dev/null -w '%{http_code}' http://$(ELK_IP):$(ELASTICSEARCH_PORT) 2>/dev/null || echo 'DOWN')"
	@echo "Kibana: $$(curl -s -o /dev/null -w '%{http_code}' http://$(ELK_IP):$(KIBANA_PORT) 2>/dev/null || echo 'DOWN')"
	@echo "Grafana: $$(curl -s -o /dev/null -w '%{http_code}' http://$(GRAFANA_IP):$(GRAFANA_PORT) 2>/dev/null || echo 'DOWN')"
	@echo "Zabbix: $$(curl -s -o /dev/null -w '%{http_code}' http://$(ZABBIX_IP):$(ZABBIX_PORT) 2>/dev/null || echo 'DOWN')"

ssh-config:
	@echo "Host monitoring-prometheus" >> ~/.ssh/config
	@echo "    HostName $(PROMETHEUS_IP)" >> ~/.ssh/config
	@echo "    User root" >> ~/.ssh/config
	@echo "Host monitoring-elk" >> ~/.ssh/config
	@echo "    HostName $(ELK_IP)" >> ~/.ssh/config
	@echo "    User root" >> ~/.ssh/config
	@echo "Host monitoring-grafana" >> ~/.ssh/config
	@echo "    HostName $(GRAFANA_IP)" >> ~/.ssh/config
	@echo "    User root" >> ~/.ssh/config
	@echo "Host monitoring-zabbix" >> ~/.ssh/config
	@echo "    HostName $(ZABBIX_IP)" >> ~/.ssh/config
	@echo "    User root" >> ~/.ssh/config
	@echo "$(GREEN)SSH config updated$(NC)"

check:
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible -i ansible/inventory/hosts.ini all -m ping

quick-deploy: apply deploy-all deploy-services-portal
	@echo "$(GREEN)Deployment complete!$(NC)"
	@echo "Prometheus: http://$(PROMETHEUS_IP):$(PROMETHEUS_PORT)"
	@echo "Elasticsearch: http://$(ELK_IP):$(ELASTICSEARCH_PORT)"
	@echo "Kibana: http://$(ELK_IP):$(KIBANA_PORT)"
	@echo "Grafana: http://$(GRAFANA_IP):$(GRAFANA_PORT)"
	@echo "Zabbix: http://$(ZABBIX_IP):$(ZABBIX_PORT)"
