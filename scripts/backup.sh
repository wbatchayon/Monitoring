#!/bin/bash
# Configuration backup script

set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="monitoring_backup_$TIMESTAMP"

error() { echo "ERROR: $*" >&2; exit 1; }
success() { echo "✓ $*"; }

echo "Starting backup..."

mkdir -p "$BACKUP_DIR/$BACKUP_NAME"

echo "Backing up Terraform..."
[ -d "terraform" ] && cp -r terraform/modules terraform/env "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || true

echo "Backing up Ansible..."
[ -d "ansible" ] && cp -r ansible/inventory ansible/playbooks ansible/roles "$BACKUP_DIR/$BACKUP_NAME/ansible/" 2>/dev/null || true

echo "Backing up Terraform variables..."
[ -f "terraform/env/dev/terraform.tfvars.example" ] && cp "terraform/env/dev/terraform.tfvars.example" "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || true

echo "Backing up documentation..."
cp -r docs "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || true

cd "$BACKUP_DIR" || error "Cannot access $BACKUP_DIR"
tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME" || error "Failed archive"
rm -rf "$BACKUP_NAME"

success "Backup created: $BACKUP_DIR/${BACKUP_NAME}.tar.gz"

echo "Cleaning old backups..."
ls -t monitoring_backup_*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm -f
success "Cleanup done"

echo "Backup complete!"
