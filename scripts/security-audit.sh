#!/bin/bash
# Security Audit Script
# Verifies the monitoring infrastructure for security issues

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
CHECKS=0

# Functions
log_check() {
    echo -e "${YELLOW}[*]${NC} $1"
    ((CHECKS++))
}

log_pass() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_fail() {
    echo -e "${RED}[✗]${NC} $1"
    ((ERRORS++))
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
    ((WARNINGS++))
}

# Header
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        SECURITY AUDIT - MONITORING INFRASTRUCTURE            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""


# TERRAFORM SECURITY

echo "📋 TERRAFORM SECURITY CHECKS"
echo "────────────────────────────────────────────────────────────────"

log_check "Checking terraform.tfvars for exposed secrets..."
if ! grep -r "password\|token_secret\|api_key\|private_key" terraform/env/*/terraform.tfvars 2>/dev/null | grep -v "# " | grep -v "=.*\$"; then
    log_pass "No hardcoded secrets in terraform.tfvars"
else
    log_fail "Found hardcoded secrets in terraform.tfvars"
fi

log_check "Checking for .tfvars files in git..."
if git check-ignore terraform/env/*/terraform.tfvars >/dev/null 2>&1; then
    log_pass "terraform.tfvars properly gitignored"
else
    log_warn "terraform.tfvars might not be properly protected"
fi

log_check "Checking sensitive variable declarations..."
if grep -q "sensitive *= *true" terraform/env/dev/variables.tf; then
    log_pass "Sensitive variables marked correctly"
else
    log_fail "Missing 'sensitive = true' declarations"
fi

echo ""


# ANSIBLE SECURITY

echo "📋 ANSIBLE SECURITY CHECKS"
echo "────────────────────────────────────────────────────────────────"

log_check "Checking for no_log in sensitive tasks..."
NOLOG_COUNT=$(grep -r "no_log.*true" ansible/roles/ --include="*.yml" 2>/dev/null | wc -l)
if [ "$NOLOG_COUNT" -gt 0 ]; then
    log_pass "Found $NOLOG_COUNT tasks with no_log protection"
else
    log_warn "No tasks with no_log found - consider adding for sensitive operations"
fi

log_check "Checking vault encryption..."
if file ansible/group_vars/all/vault.yml | grep -q "encrypted"; then
    log_pass "vault.yml is encrypted"
else
    log_fail "vault.yml appears to be unencrypted"
fi

log_check "Checking ansible.cfg for log security..."
if grep -q "no_log_values" ansible/ansible.cfg; then
    log_pass "ansible.cfg has secret masking configured"
else
    log_warn "ansible.cfg could include more comprehensive log protection"
fi

log_check "Checking for plaintext passwords in playbooks/roles..."
if ! grep -r "password.*:.*['\"]" ansible/playbooks/ ansible/roles/ 2>/dev/null | grep -v ".j2" | grep -v "default(" | grep -v "|"; then
    log_pass "No plaintext passwords found in code"
else
    log_fail "Found potential plaintext passwords in code"
fi

echo ""


# FILE & FOLDER SECURITY

echo "📋 FILE & FOLDER SECURITY CHECKS"
echo "────────────────────────────────────────────────────────────────"

log_check "Checking vault password file permissions..."
if [ -f .vault_password_file ]; then
    PERMS=$(stat -f%A .vault_password_file 2>/dev/null || stat -c%a .vault_password_file 2>/dev/null)
    if [ "$PERMS" = "600" ]; then
        log_pass ".vault_password_file has restrictive permissions (600)"
    else
        log_fail ".vault_password_file has insecure permissions ($PERMS)"
    fi
else
    log_warn ".vault_password_file not found"
fi

log_check "Checking for exposed SSH keys..."
if ! find . -name "*.pem" -o -name "id_rsa*" -o -name "*.key" 2>/dev/null | grep -v ".git"; then
    log_pass "No SSH keys found in repository"
else
    log_fail "Found potential SSH keys in repository"
fi

log_check "Checking .gitignore for security patterns..."
if grep -q "vault_password\|\.tfvars\|\.env\|*.key\|*.pem" .gitignore; then
    log_pass ".gitignore includes security patterns"
else
    log_fail ".gitignore missing critical patterns"
fi

echo ""


# SCRIPT SECURITY

echo "📋 SCRIPT SECURITY CHECKS"
echo "────────────────────────────────────────────────────────────────"

log_check "Checking bash script headers..."
if grep -q "set -euo pipefail" scripts/*.sh; then
    log_pass "Bash scripts use proper error handling"
else
    log_warn "Some bash scripts missing error handling"
fi

log_check "Checking script permissions..."
for script in scripts/*.sh; do
    PERMS=$(stat -f%A "$script" 2>/dev/null || stat -c%a "$script" 2>/dev/null)
    if [[ "$PERMS" == *"x"* ]]; then
        log_pass "$(basename $script) is executable"
    else
        log_warn "$(basename $script) is not executable"
    fi
done

echo ""


# NETWORK & FIREWALL SECURITY

echo "📋 NETWORK & FIREWALL SECURITY CHECKS"
echo "────────────────────────────────────────────────────────────────"

log_check "Checking for hardcoded IPs without ranges..."
if grep -r "192.168.1\." terraform/modules/ ansible/roles/ 2>/dev/null | grep -v "192.168.1.0/24" | grep -v "# "; then
    log_warn "Found hardcoded IPs that should use variables"
else
    log_pass "Network configuration uses proper CIDR notation"
fi

log_check "Checking firewall configuration..."
if grep -r "enable_firewall\|ufw\|firewalld" ansible/roles/Common/ >/dev/null 2>&1; then
    log_pass "Firewall configuration enabled"
else
    log_fail "Firewall configuration not found"
fi

echo ""


# SUMMARY

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                      AUDIT SUMMARY                          ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║ Total Checks Run:    $CHECKS"
echo "║ Passed:              $(($CHECKS - ERRORS - WARNINGS))"
echo "║ Warnings:            $WARNINGS"
echo "║ Errors:              $ERRORS"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✓ Security audit passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Security audit found $ERRORS critical issues${NC}"
    exit 1
fi
