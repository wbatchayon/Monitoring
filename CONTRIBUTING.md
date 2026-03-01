# Contributing to Monitoring Infrastructure

Thank you for considering contributing to this project!

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported
2. Create a detailed issue with:
   - Clear title
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details

### Suggesting Features

1. Open an issue with `[FEATURE]` prefix
2. Explain the use case
3. Provide examples if possible

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Run tests/linters: `make check`
5. Commit with clear messages
6. Push to your fork
7. Submit a Pull Request

## Development Setup

```bash
# Clone the repository
git clone https://github.com/your-username/Monitoring.git
cd Monitoring

# Install dependencies
pip install ansible ansible-lint yamllint terraform

# Run tests
make check
```

## Code Style

- Ansible: Follow [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- Terraform: Follow [Terraform Style Guide](https://www.terraform.io/docs/cloud/guides/recommended-practices/style-guide.html)
- YAML: Use `.yamllint` configuration
- Bash: Use `shellcheck` for scripts

## Security Considerations

- Never commit secrets or credentials
- Use environment variables for sensitive data
- Keep dependencies updated
- Run security audits: `scripts/security-audit.sh`

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
