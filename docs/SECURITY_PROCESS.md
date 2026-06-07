# FuzzPM Security Process

This document describes the security processes and tools used in the FuzzPM project to maintain code quality and identify vulnerabilities.

---

## Table of Contents

- [Overview](#overview)
- [Security Tools](#security-tools)
- [Automated Security Checks](#automated-security-checks)
- [Reporting Security Issues](#reporting-security-issues)
- [Security Workflow](#security-workflow)

---

## Overview

FuzzPM employs a multi-layered security approach combining automated security scanning tools with manual review processes. The project uses:

- **SCA (Software Composition Analysis)**: Bunkai for identifying vulnerable dependencies
- **SAST (Static Application Security Testing)**: Zarn for static code analysis
- **Dependency Management**: Dependabot for automated dependency updates and vulnerability alerts
- **Secret Scanning**: GitHub secret scanning for detecting exposed secrets
- **Manual Security Review**: Code review and security assessment
- **Responsible Disclosure**: Email-based security reporting process

---

## Security Tools

### Bunkai - Software Composition Analysis (SCA)

**Purpose**: Identifies vulnerable dependencies in the project

Bunkai scans the project's dependencies (defined in `cpanfile` and target-specific `cpanfile` files) to detect known vulnerabilities in Perl modules and their dependencies.

**What it checks**:
- Known CVEs in dependencies
- Outdated packages with security issues
- Vulnerable transitive dependencies

**Integration**: Automated scanning runs as part of the CI/CD pipeline

**Usage**: Results are reviewed during the security gate workflow

### Zarn - Static Application Security Testing (SAST)

**Purpose**: Performs static code analysis to identify security vulnerabilities in the source code

Zarn analyzes the Perl source code for common security issues and coding patterns that could lead to vulnerabilities.

**What it checks**:
- Security anti-patterns
- Potential injection vulnerabilities
- Unsafe file operations
- Input validation issues
- Other security code smells

**Integration**: Automated scanning runs via the `zarn.yml` workflow in CI/CD

**Usage**: Results are reviewed and addressed before merging code

### Dependabot - Automated Dependency Updates

**Purpose**: Automatically monitors dependencies and creates pull requests to update vulnerable packages

Dependabot continuously monitors the project's dependencies (defined in `cpanfile` files) and automatically creates pull requests when:

- New vulnerabilities are discovered in dependencies
- Dependency updates are available
- Security patches are released

**What it does**:
- Scans `cpanfile` and target-specific `cpanfile` files
- Checks for known vulnerabilities in dependencies
- Creates automated pull requests with dependency updates
- Provides security alerts for vulnerable dependencies

**Integration**: Configured via GitHub Dependabot settings

**Usage**: 
- Review and merge Dependabot pull requests regularly
- Address security alerts promptly
- Test dependency updates before merging

### Secret Scanning

**Purpose**: Detects exposed secrets, API keys, tokens, and credentials in the codebase

The repository runs secret scanning in CI via TruffleHog (`.github/workflows/secret-scanning.yml`). GitHub Secret Scanning may also be enabled at the repository settings level.

**What it detects**:
- API keys and tokens
- Passwords and credentials
- Private keys
- Access tokens
- Other sensitive information

**Integration**: CI workflow (`secret-scanning.yml`) with TruffleHog

**Usage**: 
- Immediate alerts when secrets are detected
- Automatic revocation for supported service providers
- Manual review and rotation of exposed secrets

---

## Automated Security Checks

### CI/CD Integration

Security checks are integrated into the project's continuous integration pipeline:

1. **Zarn Workflow** (`zarn.yml`): Runs SAST analysis on every pull request and push
2. **Security Gate Workflow** (`security-gate.yml`): Runs SCA analysis using Bunkai and other security checks
3. **Dependabot**: Continuously monitors dependencies and creates update PRs
4. **Secret Scanning**: TruffleHog scans pull requests and pushes for exposed secrets

### Workflow Process

1. **On Pull Request**: Security scans run automatically
2. **Results Review**: Maintainers review security scan results
3. **Fix Requirements**: Security issues must be addressed before merge
4. **Continuous Monitoring**: Regular scans ensure ongoing security

### Security Gate

The security gate workflow ensures that:

- No high-severity vulnerabilities are introduced
- Dependencies are scanned for known vulnerabilities
- Code passes security analysis checks
- No secrets are exposed in the codebase
- Security best practices are maintained

### Dependabot Alerts

Dependabot provides:

- **Security Alerts**: Notifications when vulnerabilities are found in dependencies
- **Automated PRs**: Pull requests with dependency updates
- **Dependency Graph**: Visualization of dependency relationships
- **Update Scheduling**: Configurable update frequency

### Secret Scanning Alerts

When secrets are detected:

- **Immediate Notification**: Alert sent to repository maintainers
- **Automatic Revocation**: Supported service providers can automatically revoke exposed secrets
- **Remediation**: Secrets must be removed from history and rotated

---

## Reporting Security Issues

### How to Report

If you discover a security vulnerability in FuzzPM, please follow responsible disclosure practices:

**Email**: [security@heitorgouvea.me](mailto:security@heitorgouvea.me)

**Important**: Do NOT submit security issues via the public issue tracker. Use email for responsible disclosure.

### What to Include

When reporting a security issue, please provide:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Suggested fix (if available)
- Your contact information

### Response Process

- **Acknowledgment**: You will receive an acknowledgment within 24 hours
- **Assessment**: The security team will assess the issue
- **Fix Development**: A fix will be developed and tested
- **Disclosure**: Coordinated disclosure after the fix is available

### What to Report

Report any security-related issues including:

- Vulnerabilities found by security tools
- Security issues discovered during code review
- Vulnerabilities in dependencies
- Security concerns in the architecture
- Any other security-related findings

---

## Security Workflow

### Development Workflow

1. **Code Changes**: Developer creates feature or fix
2. **Automated Scans**: CI/CD runs Zarn (SAST), Bunkai (SCA), and secret scanning
3. **Dependabot Checks**: Dependabot monitors for dependency vulnerabilities
4. **Review Results**: Developer and maintainers review scan results
5. **Address Issues**: Fix any security issues identified
6. **Re-scan**: Verify fixes resolve security concerns
7. **Merge**: Code is merged after security checks pass

### Dependency Management

1. **Dependabot Monitoring**: Continuous monitoring of dependencies for vulnerabilities
2. **Dependabot PRs**: Review and merge automated dependency update pull requests
3. **Bunkai Scanning**: Automated scanning for vulnerable dependencies
4. **Vulnerability Assessment**: Review of identified vulnerabilities from multiple sources
5. **Update or Mitigate**: Update dependencies or apply mitigations
6. **Testing**: Test dependency updates before merging
7. **Documentation**: Document any security-related dependency changes

### Security Maintenance

1. **Regular Scans**: Automated security scans run continuously
2. **Dependency Monitoring**: Dependabot and Bunkai monitor for new vulnerabilities
3. **Secret Monitoring**: Secret scanning continuously checks for exposed credentials
4. **Dependabot PRs**: Regularly review and merge dependency updates
5. **Code Review**: Security-focused code review for all changes
6. **Documentation**: Keep security documentation up to date

---

## Security Best Practices

### For Contributors

- Review security scan results before submitting PRs
- Address security issues identified by automated tools
- Never commit secrets, API keys, or credentials to the repository
- Review and test Dependabot pull requests
- Follow secure coding practices
- Keep dependencies updated
- Report security concerns via email

### For Maintainers

- Review all security scan results
- Respond promptly to Dependabot alerts and PRs
- Address secret scanning alerts immediately
- Prioritize high-severity vulnerabilities
- Ensure security fixes are properly tested
- Coordinate security disclosures
- Maintain security tooling and configurations
- Rotate any exposed secrets immediately

---

## Security Contacts

- **Security Email**: [security@heitorgouvea.me](mailto:security@heitorgouvea.me)
- **Security Policy**: [SECURITY.md](../SECURITY.md)

---

## References

- [Bunkai Documentation](https://github.com/htrgouvea/bunkai)
- [Zarn Documentation](https://github.com/htrgouvea/zarn)
- [Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [Perl Security](https://perldoc.perl.org/perlsec)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
