#!/bin/bash
# SSH configuration for monitoring VMs - uses environment variables

set -e

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

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Configuring SSH...${NC}"

SSH_DIR="$HOME/.ssh"
CONFIG_FILE="$SSH_DIR/config"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

[ ! -f "$CONFIG_FILE" ] && touch "$CONFIG_FILE" && chmod 600 "$CONFIG_FILE"

if ! grep -q "monitoring-prometheus" "$CONFIG_FILE" 2>/dev/null; then
    cat >> "$CONFIG_FILE" << EOF

Host monitoring-prometheus
    HostName ${PROMETHEUS_IP}
    User root
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host monitoring-elk
    HostName ${ELK_IP}
    User root
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host monitoring-grafana
    HostName ${GRAFANA_IP}
    User root
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host monitoring-zabbix
    HostName ${ZABBIX_IP}
    User root
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
    echo -e "${GREEN}SSH config added!${NC}"
else
    echo -e "${GREEN}Config exists.${NC}"
fi

echo -e "${YELLOW}Testing connections...${NC}"
for vm in prometheus elk grafana zabbix; do
    echo -n "  $vm: "
    timeout 2 ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no "monitoring-$vm" "echo OK" 2>/dev/null && echo -e "${GREEN}OK${NC}" || echo -e "${YELLOW}Not reachable${NC}"
done

echo -e "${GREEN}Done!${NC} Connect: ssh monitoring-{prometheus,elk,grafana,zabbix}"
