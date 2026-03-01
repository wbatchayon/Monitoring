#!/bin/bash
# Monitoring Infrastructure Test Script
# Tests all monitoring services via HTTP APIs

set -uo pipefail

# Load environment variables if .env exists
if [ -f "$(dirname "$0")/../.env" ]; then
    set -a
    source "$(dirname "$0")/../.env"
    set +a
fi

# Default values
PROMETHEUS_IP="${PROMETHEUS_IP:-192.168.1.110}"
GRAFANA_IP="${GRAFANA_IP:-192.168.1.112}"
ELK_IP="${ELK_IP:-192.168.1.111}"
ZABBIX_IP="${ZABBIX_IP:-192.168.1.113}"

PROMETHEUS_PORT="${PROMETHEUS_PORT:-9090}"
GRAFANA_PORT="${GRAFANA_PORT:-3000}"
ELASTICSEARCH_PORT="${ELASTICSEARCH_PORT:-9200}"
KIBANA_PORT="${KIBANA_PORT:-5601}"
ZABBIX_PORT="${ZABBIX_PORT:-8080}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
PASS_COUNT=0
FAIL_COUNT=0

# Functions
test_pass() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((PASS_COUNT++)) || true
}

test_fail() {
    echo -e "${RED}[✗]${NC} $1"
    ((FAIL_COUNT++)) || true
}

test_info() {
    echo -e "${YELLOW}[ℹ]${NC} $1"
}

test_header() {
    echo ""
    echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
}

# Header
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║       MONITORING INFRASTRUCTURE TEST SUITE                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""


# PROMETHEUS TESTS

test_header "PROMETHEUS TESTS"

# Test 1: Prometheus is running
echo -e "\n${CYAN}Testing Prometheus availability...${NC}"
if curl -sf "http://${PROMETHEUS_IP}:${PROMETHEUS_PORT}/-/healthy" >/dev/null 2>&1; then
    test_pass "Prometheus is running and healthy"
else
    test_fail "Prometheus is not accessible"
fi

# Test 2: Prometheus API is responding
echo -e "\n${CYAN}Testing Prometheus API...${NC}"
if curl -sf "http://${PROMETHEUS_IP}:${PROMETHEUS_PORT}/api/v1/status/config" >/dev/null 2>&1; then
    test_pass "Prometheus API is responding"
else
    test_fail "Prometheus API is not responding"
fi

# Test 3: Check Prometheus targets
echo -e "\n${CYAN}Checking Prometheus targets...${NC}"
TARGETS=$(curl -s "http://${PROMETHEUS_IP}:${PROMETHEUS_PORT}/api/v1/targets" 2>/dev/null | grep -o '"health":"up"' | wc -l || echo "0")
if [ "$TARGETS" -gt 0 ]; then
    test_pass "Found $TARGETS healthy targets in Prometheus"
else
    test_fail "No healthy targets found in Prometheus"
fi

# Test 4: Check node_exporter metrics
echo -e "\n${CYAN}Checking node_exporter metrics...${NC}"
if curl -sf "http://${PROMETHEUS_IP}:9100/metrics" 2>/dev/null | grep -q "node_"; then
    test_pass "node_exporter metrics are available"
else
    test_fail "node_exporter metrics not found"
fi

# Test 5: Query a metric from Prometheus
echo -e "\n${CYAN}Testing Prometheus query...${NC}"
METRIC_RESULT=$(curl -s "http://${PROMETHEUS_IP}:${PROMETHEUS_PORT}/api/v1/query?query=up" 2>/dev/null | grep -o '"value"' | wc -l || echo "0")
if [ "$METRIC_RESULT" -gt 0 ]; then
    test_pass "Prometheus can query metrics"
else
    test_fail "Prometheus query failed"
fi


# GRAFANA TESTS

test_header "GRAFANA TESTS"

# Test 1: Grafana is running
echo -e "\n${CYAN}Testing Grafana availability...${NC}"
if curl -sf -u "admin:admin" "http://${GRAFANA_IP}:${GRAFANA_PORT}/api/health" >/dev/null 2>&1; then
    test_pass "Grafana is running and healthy"
else
    test_fail "Grafana is not accessible"
fi

# Test 2: Grafana datasources
echo -e "\n${CYAN}Checking Grafana datasources...${NC}"
DATASOURCES=$(curl -s -u "admin:admin" "http://${GRAFANA_IP}:${GRAFANA_PORT}/api/datasources" 2>/dev/null | grep -o '"uid"' | wc -l || echo "0")
if [ "$DATASOURCES" -gt 0 ]; then
    test_pass "Found $DATASOURCES datasources in Grafana"
else
    test_info "No datasources configured in Grafana"
fi

# Test 3: Grafana dashboards
echo -e "\n${CYAN}Checking Grafana dashboards...${NC}"
DASHBOARDS=$(curl -s -u "admin:admin" "http://${GRAFANA_IP}:${GRAFANA_PORT}/api/search?type=dash-db" 2>/dev/null | grep -o '"uid"' | wc -l || echo "0")
if [ "$DASHBOARDS" -gt 0 ]; then
    test_pass "Found $DASHBOARDS dashboards in Grafana"
else
    test_info "No dashboards found in Grafana"
fi


# ELASTICSEARCH/KIBANA TESTS

test_header "ELASTICSEARCH/KIBANA TESTS"

# Test 1: Elasticsearch is running
echo -e "\n${CYAN}Testing Elasticsearch availability...${NC}"
if curl -sf "http://${ELK_IP}:${ELASTICSEARCH_PORT}/_cluster/health" >/dev/null 2>&1; then
    test_pass "Elasticsearch is running"
else
    test_fail "Elasticsearch is not accessible"
fi

# Test 2: Elasticsearch cluster health
echo -e "\n${CYAN}Checking Elasticsearch cluster health...${NC}"
CLUSTER_STATUS=$(curl -s "http://${ELK_IP}:${ELASTICSEARCH_PORT}/_cluster/health" 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
if [ "$CLUSTER_STATUS" = "green" ] || [ "$CLUSTER_STATUS" = "yellow" ]; then
    test_pass "Elasticsearch cluster status: $CLUSTER_STATUS"
else
    test_fail "Elasticsearch cluster status: $CLUSTER_STATUS"
fi

# Test 3: Kibana is running
echo -e "\n${CYAN}Testing Kibana availability...${NC}"
if curl -sf "http://${ELK_IP}:${KIBANA_PORT}/api/status" >/dev/null 2>&1; then
    test_pass "Kibana is running and healthy"
else
    test_fail "Kibana is not accessible"
fi

# Test 4: Check indices
echo -e "\n${CYAN}Checking Elasticsearch indices...${NC}"
INDICES=$(curl -s "http://${ELK_IP}:${ELASTICSEARCH_PORT}/_cat/indices" 2>/dev/null | wc -l || echo "0")
if [ "$INDICES" -gt 0 ]; then
    test_pass "Found $INDICES indices in Elasticsearch"
else
    test_info "No indices found in Elasticsearch"
fi


# ZABBIX TESTS

test_header "ZABBIX TESTS"

# Test 1: Zabbix web interface
echo -e "\n${CYAN}Testing Zabbix web interface...${NC}"
if curl -sf "http://${ZABBIX_IP}:${ZABBIX_PORT}/zabbix/" 2>/dev/null | grep -q "Zabbix"; then
    test_pass "Zabbix web interface is accessible"
else
    test_fail "Zabbix web interface is not accessible"
fi

# Test 2: Zabbix API
echo -e "\n${CYAN}Testing Zabbix API...${NC}"
AUTH_RESPONSE=$(curl -s -X POST "http://${ZABBIX_IP}:${ZABBIX_PORT}/zabbix/api_jsonrpc.php" \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"user.login","params":{"username":"Admin","password":"zabbix"},"id":1}' 2>/dev/null)

AUTH_TOKEN=$(echo "$AUTH_RESPONSE" | grep -o '"result":"[^"]*"' | cut -d'"' -f4 || echo "")

if [ -n "$AUTH_TOKEN" ]; then
    test_pass "Zabbix API is working (authenticated)"
else
    test_fail "Zabbix API authentication failed"
fi

# Test 3: Get Zabbix version
if [ -n "$AUTH_TOKEN" ]; then
    echo -e "\n${CYAN}Checking Zabbix version...${NC}"
    VERSION=$(curl -s -X POST "http://${ZABBIX_IP}:${ZABBIX_PORT}/zabbix/api_jsonrpc.php" \
        -H "Content-Type: application/json" \
        -d "{\"jsonrpc\":\"2.0\",\"method\":\"apiinfo.version\",\"params\":[],\"id\":1}" 2>/dev/null \
        | grep -o '"result":"[^"]*"' | cut -d'"' -f4 || echo "")
    if [ -n "$VERSION" ]; then
        test_pass "Zabbix version: $VERSION"
    fi
fi

# Test 4: Check hosts in Zabbix
if [ -n "$AUTH_TOKEN" ]; then
    echo -e "\n${CYAN}Checking Zabbix hosts...${NC}"
    HOSTS=$(curl -s -X POST "http://${ZABBIX_IP}:${ZABBIX_PORT}/zabbix/api_jsonrpc.php" \
        -H "Content-Type: application/json" \
        -d "{\"jsonrpc\":\"2.0\",\"method\":\"host.get\",\"params\":{\"output\":\"extend\"},\"auth\":\"${AUTH_TOKEN}\",\"id\":1}" 2>/dev/null \
        | grep -o '"hostid"' | wc -l || echo "0")
    if [ "$HOSTS" -gt 0 ]; then
        test_pass "Found $HOSTS hosts in Zabbix"
    else
        test_info "No hosts configured in Zabbix (agent may not be running)"
    fi
fi


# SERVICE PORTAL TEST

test_header "SERVICES PORTAL TEST"

echo -e "\n${CYAN}Testing Services Portal availability...${NC}"
if curl -sf "http://${PROMETHEUS_IP}:80" >/dev/null 2>&1; then
    test_pass "Services Portal is accessible"
else
    test_fail "Services Portal is not accessible"
fi


# SUMMARY

test_header "TEST SUMMARY"

TOTAL=$((PASS_COUNT + FAIL_COUNT))
if [ "$TOTAL" -gt 0 ]; then
    PASS_PERCENT=$((PASS_COUNT * 100 / TOTAL))
else
    PASS_PERCENT=0
fi

echo ""
echo "Tests Run:    $TOTAL"
echo "Passed:       $PASS_COUNT (${PASS_PERCENT}%)"
echo "Failed:       $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ ALL TESTS PASSED - INFRASTRUCTURE IS WORKING     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Access your monitoring services at:"
    echo "  - Prometheus:    http://${PROMETHEUS_IP}:${PROMETHEUS_PORT}"
    echo "  - Grafana:       http://${GRAFANA_IP}:${GRAFANA_PORT} (admin/admin)"
    echo "  - Kibana:        http://${ELK_IP}:${KIBANA_PORT}"
    echo "  - Zabbix:        http://${ZABBIX_IP}:${ZABBIX_PORT}/zabbix (Admin/zabbix)"
    echo "  - Services:      http://${PROMETHEUS_IP}:80"
    exit 0
else
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠ SOME TESTS FAILED - REVIEW RESULTS ABOVE          ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Common issues:"
    echo "  - Services may need a few minutes to start up after deployment"
    echo "  - Check service status with: make status"
    exit 1
fi
