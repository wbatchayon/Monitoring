#!/bin/bash
# Infrastructure Testing Script
# Validates Terraform and Ansible configurations

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
PASS_COUNT=0
FAIL_COUNT=0

# Functions
test_pass() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((PASS_COUNT++))
}

test_fail() {
    echo -e "${RED}[✗]${NC} $1"
    ((FAIL_COUNT++))
}

test_header() {
    echo ""
    echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
}

# Header
clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║    INFRASTRUCTURE VALIDATION & TESTING SUITE                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""


# TERRAFORM TESTS

test_header "TERRAFORM VALIDATION TESTS"

# Test 1: Check Terraform installation
if command -v terraform &> /dev/null; then
    TF_VERSION=$(terraform version | head -1)
    test_pass "Terraform installed: $TF_VERSION"
else
    test_fail "Terraform not found - install with: brew install terraform"
fi

# Test 2: Dev environment syntax
echo -e "\n${YELLOW}Testing dev environment...${NC}"
if cd terraform/env/dev && terraform fmt -check -recursive . >/dev/null 2>&1; then
    test_pass "Dev terraform formatting is valid"
    cd ../../..
else
    test_fail "Dev terraform formatting has issues"
    cd ../../..
fi

# Test 3: Prod environment syntax
echo -e "\n${YELLOW}Testing prod environment...${NC}"
if cd terraform/env/prod && terraform fmt -check -recursive . >/dev/null 2>&1; then
    test_pass "Prod terraform formatting is valid"
    cd ../../..
else
    test_fail "Prod terraform formatting has issues"
    cd ../../..
fi

# Test 4: Stag environment syntax
echo -e "\n${YELLOW}Testing stag environment...${NC}"
if cd terraform/env/stag && terraform fmt -check -recursive . >/dev/null 2>&1; then
    test_pass "Stag terraform formatting is valid"
    cd ../../..
else
    test_fail "Stag terraform formatting has issues"
    cd ../../..
fi


# ANSIBLE TESTS

test_header "ANSIBLE VALIDATION TESTS"

# Test 1: Check Ansible installation
if command -v ansible-playbook &> /dev/null; then
    ANSIBLE_VERSION=$(ansible-playbook --version | head -1)
    test_pass "Ansible installed: $ANSIBLE_VERSION"
else
    test_fail "Ansible not found - install with: pip install ansible"
fi

# Test 2: Validate playbook syntax
echo -e "\n${YELLOW}Checking playbook syntax...${NC}"
PLAYBOOK_ERRORS=0
for playbook in ansible/playbooks/*.yml; do
    if ansible-playbook --syntax-check "$playbook" >/dev/null 2>&1; then
        test_pass "$(basename $playbook) syntax valid"
    else
        test_fail "$(basename $playbook) has syntax errors"
        ((PLAYBOOK_ERRORS++))
    fi
done

# Test 3: Check Ansible inventory
echo -e "\n${YELLOW}Checking inventory...${NC}"
if [ -f ansible/inventory/hosts.ini ]; then
    HOSTS=$(grep -c "^\[" ansible/inventory/hosts.ini || echo "0")
    test_pass "Inventory file exists with $HOSTS groups"
else
    test_fail "Inventory file not found at ansible/inventory/hosts.ini"
fi

# Test 4: Check role structures
echo -e "\n${YELLOW}Checking role structures...${NC}"
ROLES=("Common" "Prometheus" "ELK" "Grafana" "Zabbix" "services")
for role in "${ROLES[@]}"; do
    ROLE_PATH="ansible/roles/$role"
    if [ -d "$ROLE_PATH/tasks" ] && [ -f "$ROLE_PATH/tasks/main.yml" ]; then
        test_pass "Role '$role' structure valid"
    else
        test_fail "Role '$role' missing tasks/main.yml"
    fi
done


# SECURITY TESTS

test_header "SECURITY VALIDATION TESTS"

# Test 1: Run security audit
echo -e "\n${YELLOW}Running security audit...${NC}"
if bash scripts/security-audit.sh >/dev/null 2>&1; then
    test_pass "Security audit passed"
else
    test_fail "Security audit detected issues"
fi

# Test 2: Check for exposed secrets
echo -e "\n${YELLOW}Checking for exposed secrets...${NC}"
if ! grep -r "password.*=" terraform/env/*/terraform.tfvars 2>/dev/null | grep -v "#" | grep -v "default"; then
    test_pass "No hardcoded passwords in terraform.tfvars"
else
    test_fail "Found hardcoded passwords in terraform files"
fi


# CONFIGURATION TESTS

test_header "CONFIGURATION VALIDATION TESTS"

# Test 1: Check ansible.cfg
if [ -f ansible/ansible.cfg ]; then
    test_pass "ansible.cfg exists"
    if grep -q "vault_password_file" ansible/ansible.cfg; then
        test_pass "Vault configuration present in ansible.cfg"
    else
        test_fail "Vault configuration missing from ansible.cfg"
    fi
else
    test_fail "ansible.cfg not found"
fi

# Test 2: Check vault encryption
echo -e "\n${YELLOW}Checking vault encryption...${NC}"
if [ -f ansible/group_vars/all/vault.yml ]; then
    if head -1 ansible/group_vars/all/vault.yml | grep -q "\$ANSIBLE_VAULT"; then
        test_pass "vault.yml is encrypted"
    else
        test_fail "vault.yml appears unencrypted"
    fi
else
    test_fail "vault.yml not found"
fi


# FILE & SCRIPT TESTS

test_header "SCRIPT & FILE VALIDATION TESTS"

# Test 1: Check script properties
echo -e "\n${YELLOW}Checking script properties...${NC}"
SCRIPTS=("deploy-infrastructure.sh" "backup.sh" "check-status.sh" "setup-ssh.sh" "security-audit.sh")
for script in "${SCRIPTS[@]}"; do
    SCRIPT_PATH="scripts/$script"
    if [ -f "$SCRIPT_PATH" ]; then
        if [ -x "$SCRIPT_PATH" ]; then
            test_pass "$script is executable"
        else
            test_fail "$script is not executable (chmod +x needed)"
        fi
    else
        test_fail "$script not found"
    fi
done

# Test 2: Check documentation
echo -e "\n${YELLOW}Checking documentation...${NC}"
DOCS=("README.md" "NEXT_STEPS.md" "PRODUCTION_READINESS.md" "GIT_SETUP_GUIDE.md")
for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        test_pass "Documentation file exists: $doc"
    else
        test_fail "Missing documentation: $doc"
    fi
done


# SUMMARY

test_header "TEST SUMMARY"

TOTAL=$((PASS_COUNT + FAIL_COUNT))
PASS_PERCENT=$((PASS_COUNT * 100 / TOTAL))

echo ""
echo "Tests Run:    $TOTAL"
echo "Passed:       $PASS_COUNT (${PASS_PERCENT}%)"
echo "Failed:       $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ ALL TESTS PASSED - INFRASTRUCTURE READY FOR USE    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ✗ $FAIL_COUNT TEST(S) FAILED - FIX ISSUES BEFORE USE  ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    exit 1
fi
