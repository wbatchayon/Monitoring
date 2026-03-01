# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability, please send an email to the maintainer. All security vulnerabilities will be promptly addressed.

Please include the following information:

- Type of vulnerability
- Full paths of source file(s)
- Location of the affected source code
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue

## Security Best Practices

### Secrets Management

- Never commit secrets to the repository
- Use environment variables for sensitive data
- Use Ansible Vault for encrypting sensitive files
- Store vault password securely (not in the repository)

### Before Deployment

1. Review `ansible/group_vars/all/vars.yml` - ensure no real passwords
2. Review `terraform/env/*/terraform.tfvars` - ensure no secrets
3. Verify `.vault_password_file` is in `.gitignore`
4. Run security audit: `scripts/security-audit.sh`

### Network Security

- Restrict access to monitoring network (192.168.1.0/24)
- Enable UFW firewall on all VMs
- Use fail2ban for SSH protection
- Enable automatic security updates

### Access Control

- Use SSH keys instead of passwords
- Rotate passwords regularly
- Limit SSH access to specific users
- Use strong passwords for all services
