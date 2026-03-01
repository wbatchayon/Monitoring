#!/bin/bash
# Infrastructure deployment script
# Usage: ./deploy-infrastructure.sh [--auto]

set -euo pipefail

# Load environment variables if .env exists
if [ -f "$(dirname "$0")/../.env" ]; then
    set -a
    source "$(dirname "$0")/../.env"
    set +a
fi

# Default values
PROMETHEUS_IP="${PROMETHEUS_IP:-192.168.1.110}"
ELK_IP="${ELK_IP:-192.168.1.111}"
GRAFANA_IP="${GRAFANA_IP:-192.168.1.112}"
ZABBIX_IP="${ZABBIX_IP:-192.168.1.113}"

PROMETHEUS_PORT="${PROMETHEUS_PORT:-9090}"
ELASTICSEARCH_PORT="${ELASTICSEARCH_PORT:-9200}"
KIBANA_PORT="${KIBANA_PORT:-5601}"
GRAFANA_PORT="${GRAFANA_PORT:-3000}"
ZABBIX_PORT="${ZABBIX_PORT:-8080}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_DIR}/deployment.log"

log() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $*" | tee -a "$LOG_FILE"; exit 1; }
success() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS:${NC} $*" | tee -a "$LOG_FILE"; }

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Monitoring Infrastructure - Full Deployment            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

check_requirements() {
    log "Checking prerequisites..."
    command -v terraform &> /dev/null || error "Terraform not installed"
    command -v ansible-playbook &> /dev/null || error "Ansible not installed"
    success "Prerequisites satisfied."
}

init_terraform() {
    log "Initializing Terraform..."
    cd "$PROJECT_DIR/terraform/env/dev" || error "Cannot access terraform/env/dev"
    terraform init || error "Terraform init failed"
    success "Terraform initialized."
}

plan_terraform() {
    log "Planning Terraform changes..."
    cd "$PROJECT_DIR/terraform/env/dev" || error "Cannot access terraform/env/dev"
    terraform plan -out=tfplan || error "Terraform plan failed"
    success "Terraform plan completed."
}

apply_terraform() {
    log "Applying Terraform configuration..."
    cd "$PROJECT_DIR/terraform/env/dev" || error "Cannot access terraform/env/dev"
    terraform apply tfplan || error "Terraform apply failed"
    success "Infrastructure created."
}

deploy_ansible() {
    log "Deploying monitoring stack with Ansible..."
    cd "$PROJECT_DIR" || error "Cannot access project directory"
    [ -f "ansible/inventory/hosts.ini" ] || error "Inventory not found"
    ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/deploy-prometheus.yml || error "Ansible deployment failed"
    success "Monitoring stack deployed."
}

health_check() {
    log "Running health checks..."
    services=(
        "Prometheus:http://${PROMETHEUS_IP}:${PROMETHEUS_PORT}"
        "Elasticsearch:http://${ELK_IP}:${ELASTICSEARCH_PORT}"
        "Kibana:http://${ELK_IP}:${KIBANA_PORT}"
        "Grafana:http://${GRAFANA_IP}:${GRAFANA_PORT}"
        "Zabbix:http://${ZABBIX_IP}:${ZABBIX_PORT}"
    )
    for service in "${services[@]}"; do
        name="${service%%:*}"
        url="${service##*:}"
        if curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | grep -qE "200|302|401"; then
            echo -e "${GREEN}✓${NC} $name is online"
        else
            echo -e "${RED}✗${NC} $name is offline"
        fi
    done
    success "Health check completed."
}

main() {
    log "Starting deployment..."
    check_requirements
    init_terraform
    if [ "$1" != "--auto" ]; then
        log "Continue? (y/n)"
        read -r -n 1 response
        [ "$response" = "y" ] || error "Deployment cancelled"
        echo ""
    fi
    plan_terraform
    apply_terraform
    log "Waiting 60 seconds for VMs to boot..."
    sleep 60
    deploy_ansible
    health_check
    log "Deployment completed!"
    echo "  Prometheus: http://${PROMETHEUS_IP}:${PROMETHEUS_PORT}"
    echo "  Kibana: http://${ELK_IP}:${KIBANA_PORT}"
    echo "  Grafana: http://${GRAFANA_IP}:${GRAFANA_PORT}"
    echo "  Zabbix: http://${ZABBIX_IP}:${ZABBIX_PORT}"
}

deploy_vms() {
    echo -e "${YELLOW}Deploying VMs...${NC}"
    cd "$PROJECT_DIR/terraform/env/dev"
    terraform apply -auto-approve
    echo -e "${GREEN}✓ VMs deployed.${NC}"
}

deploy_services() {
    echo -e "${YELLOW}Deploying services...${NC}"
    cd "$PROJECT_DIR"
    ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/deploy-prometheus.yml
    echo -e "${GREEN}✓ Services deployed.${NC}"
}

deploy_services_portal() {
    echo -e "${YELLOW}Deploying portal...${NC}"
    cd "$PROJECT_DIR"
    ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/deploy-services-portal.yml
    echo -e "${GREEN}✓ Portal deployed.${NC}"
}

verify_deployment() {
    echo -e "${YELLOW}Verifying deployment...${NC}"
    SERVICES=(
        "Prometheus:http://${PROMETHEUS_IP}:${PROMETHEUS_PORT}"
        "Elasticsearch:http://${ELK_IP}:${ELASTICSEARCH_PORT}"
        "Kibana:http://${ELK_IP}:${KIBANA_PORT}"
        "Grafana:http://${GRAFANA_IP}:${GRAFANA_PORT}"
        "Zabbix:http://${ZABBIX_IP}:${ZABBIX_PORT}"
        "Services Portal:http://${PROMETHEUS_IP}:80"
    )
    all_ok=true
    for service in "${SERVICES[@]}"; do
        IFS=':' read -r name url <<< "$service"
        echo -n "  $name: "
        if curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | grep -qE "200|302|401"; then
            echo -e "${GREEN}● Online${NC}"
        else
            echo -e "${YELLOW}○ Pending${NC}"
            all_ok=false
        fi
    done
    [ "$all_ok" = true ] && echo -e "${GREEN}✓ All services online!${NC}" || echo -e "${YELLOW}⚠ Some services pending.${NC}"
}

show_menu() {
    echo ""
    echo "Select option:"
    echo "  1) Full deployment (VMs + Services)"
    echo "  2) Deploy VMs only"
    echo "  3) Deploy services only"
    echo "  4) Deploy portal"
    echo "  5) Verify status"
    echo "  6) Destroy infrastructure"
    echo "  0) Exit"
    echo ""
    read -p "Choice: " choice
    case $choice in
        1) check_requirements; init_terraform; deploy_vms; deploy_services; verify_deployment ;;
        2) check_requirements; init_terraform; deploy_vms ;;
        3) deploy_services ;;
        4) deploy_services_portal ;;
        5) verify_deployment ;;
        6) echo -e "${RED}Destroying...${NC}"; cd "$PROJECT_DIR/terraform/env/dev"; terraform destroy -auto-approve ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo -e "${RED}Invalid${NC}" ;;
    esac
}

if [ "$1" == "--auto" ]; then
    check_requirements
    init_terraform
    deploy_vms
    deploy_services
    verify_deployment
else
    show_menu
fi

echo ""
echo -e "${GREEN}Done!${NC}"
echo "Services: Prometheus :${PROMETHEUS_PORT}, ES :${ELASTICSEARCH_PORT}, Kibana :${KIBANA_PORT}, Grafana :${GRAFANA_PORT}, Zabbix :${ZABBIX_PORT}"
