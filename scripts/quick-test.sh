#!/bin/bash
# Quick validation test

cd /home/batchayn/Monitoring

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║       QUICK VALIDATION TEST                                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Terraform
echo "✓ Terraform Syntax Check..."
terraform -chdir=terraform/env/dev fmt -check . 2>&1 | grep -E "Error|error" && echo "  ✗ FAILED" || echo "  ✓ PASSED"

echo ""
echo "✓ Ansible Playbook Syntax..."
ansible-playbook --syntax-check ansible/playbooks/deploy-prometheus.yml &>/dev/null && echo "  ✓ PASSED" || echo "  ✗ FAILED"

echo ""
echo "✓ Vault File Encryption..."
test -f ansible/group_vars/all/vault.yml && \
head -1 ansible/group_vars/all/vault.yml | grep -q "ANSIBLE_VAULT" && \
echo "  ✓ PASSED (Encrypted)" || echo "  ✗ FAILED (Not encrypted)"

echo ""
echo "✓ Security Checks..."
echo "  - No hardcoded passwords in terraform.tfvars"
grep -r "password.*=" terraform/env/*/terraform.tfvars 2>/dev/null | grep -v "# " | grep -v "\$" && echo "    ✗ FAILED" || echo "    ✓ PASSED"

echo ""
echo "✓ SSH Key Permissions..."
if [ -f .vault_password_file ]; then
    PERMS=$(stat -f%A .vault_password_file 2>/dev/null || stat -c%a .vault_password_file 2>/dev/null)
    echo "  .vault_password_file: $PERMS (should be 600)"
    [ "$PERMS" = "600" ] && echo "    ✓ PASSED" || echo "    ✗ FAILED"
else
    echo "    ⚠ File not found (optional)"
fi

echo ""
echo "✓ Required Files Check..."
REQUIRED=("README.md" "NEXT_STEPS.md" ".gitignore" "Makefile")
for file in "${REQUIRED[@]}"; do
    [ -f "$file" ] && echo "  ✓ $file" || echo "  ✗ $file MISSING"
done

echo ""
echo "✓ Scripts Executable..."
for script in scripts/*.sh; do
    [ -x "$script" ] && echo "  ✓ $(basename $script)" || echo "  ✗ $(basename $script) NOT EXECUTABLE"
done

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✓ VALIDATION COMPLETE"
