#!/bin/bash
# Services status check - uses environment variables

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

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check() {
    echo -n "  $1: "
    curl -s -o /dev/null -w "%{http_code}" "$2" 2>/dev/null | grep -qE "200|302" && echo -e "${GREEN}ONLINE${NC}" || echo -e "${RED}OFFLINE${NC}"
}

echo "Monitoring Services Status"
echo "=========================="
check "Prometheus" "http://${PROMETHEUS_IP}:${PROMETHEUS_PORT}"
check "Elasticsearch" "http://${ELK_IP}:${ELASTICSEARCH_PORT}"
check "Kibana" "http://${ELK_IP}:${KIBANA_PORT}"
check "Grafana" "http://${GRAFANA_IP}:${GRAFANA_PORT}"
check "Zabbix" "http://${ZABBIX_IP}:${ZABBIX_PORT}"

echo ""
for vm in prometheus elk grafana zabbix; do
    echo -n "  VM $vm: "
    timeout 2 ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no "monitoring-$vm" "echo OK" 2>/dev/null && echo -e "${GREEN}REACHABLE${NC}" || echo -e "${YELLOW}UNREACHABLE${NC}"
done

echo ""
echo "Done."
