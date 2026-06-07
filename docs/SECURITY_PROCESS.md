# FuzzPM Security Process

This document describes the security processes and tools used in the FuzzPM project to maintain code quality and identify vulnerabilities.

---

## Table of Contents

- [Overview](#overview)
- [Project Security Process](#project-security-process)
- [Security Tools](#security-tools)
- [Automated Security Checks](#automated-security-checks)
- [Reporting Security Issues](#reporting-security-issues)
- [Security Workflow](#security-workflow)

---

## Overview

FuzzPM employs a multi-layered security approach combining automated security scanning tools with manual review processes. The project uses:

- **SCA (Software Composition Analysis)**: Dependabot and Bunkai for identifying vulnerable dependencies and dependency risk
- **SAST (Static Application Security Testing)**: Zarn for static code analysis
- **Dependency Management**: Dependabot for automated dependency updates and vulnerability alerts
- **Linting**: Perl::Critic for simpler, more consistent code that is easier to review safely
- **Secret Scanning**: GitHub secret scanning for detecting exposed secrets
- **Security Gate**: Centralized gating over dependency, code, and secret alerts
- **Testing**: Unit and integration tests for regression coverage
- **Manual Security Review**: Code review and security assessment
- **Responsible Disclosure**: Email-based security reporting process defined in `SECURITY.md`

---

## Project Security Process

FuzzPM treats security as part of the normal development lifecycle, not as a
separate activity after code is complete. The process is designed around four
goals:

1. Prevent unsafe inputs from reaching sensitive operations
2. Detect vulnerable dependencies and unsafe code patterns early
3. Keep security findings reproducible and testable
4. Resolve confirmed issues before they are merged or publicly disclosed

### 1. Secure Design and Implementation

Security-sensitive changes should be designed around explicit trust boundaries:

- CLI arguments and YAML case files are untrusted input
- Seed files are untrusted input
- Target module names and paths are untrusted input
- Dependency updates may change behavior and must be reviewed

When implementation touches file paths, dynamic module loading, external tools,
threading, output handling, or dependency metadata, contributors should include
validation logic and focused tests in the same change.

### Current Security Controls

The project currently uses the following controls:

| Control | Purpose | Repository file |
| --- | --- | --- |
| Dependabot | Dependency and GitHub Actions update monitoring | [`.github/dependabot.yml`](../.github/dependabot.yml) |
| Bunkai | SCA scan and SARIF upload | [`.github/workflows/bunkai.yml`](../.github/workflows/bunkai.yml) |
| Zarn | SAST scan and SARIF upload | [`.github/workflows/zarn.yml`](../.github/workflows/zarn.yml) |
| Perl::Critic linter | Keeps code simple and consistent, reducing review friction and avoidable security mistakes | [`.github/workflows/linter.yml`](../.github/workflows/linter.yml) |
| Secret scanning | TruffleHog scan for exposed secrets | [`.github/workflows/secret-scanning.yml`](../.github/workflows/secret-scanning.yml) |
| Security gate | Enforces thresholds for dependency, code, and secret alerts | [`.github/workflows/security-gate.yml`](../.github/workflows/security-gate.yml) |
| Tests | Unit, integration, and runtime validation | [`.github/workflows/test-on-ubuntu.yml`](../.github/workflows/test-on-ubuntu.yml) |
| Security policy | Private vulnerability reporting process | [`SECURITY.md`](../SECURITY.md) |

### 2. Local Validation Before Review

Before opening or updating a pull request, contributors should run the local
quality checks that match the change:

```bash
prove -l tests/
perlcritic --profile .perlcriticrc .
```

For changes that affect mutation behavior, run the mutation tests in an
environment where `Radamsa` is installed. For dependency changes, review the
updated dependency graph and confirm the project still installs cleanly.

### 3. Pull Request Review

Security review is part of normal code review. Maintainers should check that:

- Inputs are validated before use
- File and module paths cannot escape their allowed base directories
- Dynamic loading is constrained to expected target modules
- Errors do not expose sensitive data unnecessarily
- New behavior has tests for failure cases, not only successful paths
- Automated security checks pass or have a documented false-positive decision

High-risk changes should not be merged until tests and automated checks pass.

### 4. Finding Intake and Triage

Security findings may come from automated tooling, dependency alerts, manual
review, or private reports. Each finding should be triaged for:

- Affected component
- Reproduction steps
- Impact and exploitability
- Severity
- Whether the issue is already mitigated by existing controls

Findings that may expose users to risk should be handled privately through the
responsible disclosure process instead of public issues.

### 5. Remediation and Verification

Confirmed issues should be fixed with the smallest practical change that
addresses the root cause. Each fix should include:

- A regression test that fails before the fix
- Validation for malformed or hostile input where applicable
- Updated documentation when the security model or user guidance changes
- A re-run of the relevant test and security checks

For dependency vulnerabilities, remediation should prefer updating the affected
dependency. If an update is not available, maintainers should document the
temporary mitigation and revisit it regularly.

### 6. Disclosure and Follow-Up

After a security issue is fixed, maintainers should coordinate disclosure based
on impact. Follow-up work may include:

- Publishing release notes or advisory details
- Updating `SECURITY.md` or this document
- Rotating exposed credentials if secret scanning was involved
- Adding tests or checks that would have caught the issue earlier
- Recording future hardening work in `docs/FUTURE_IMPROVEMENTS.md`

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

### Dependabot - Dependency and Actions Monitoring

**Purpose**: Monitors dependency metadata and GitHub Actions updates.

Dependabot is configured in `.github/dependabot.yml` for Docker and GitHub
Actions. It helps keep the project infrastructure current and reduces exposure
to known vulnerable or outdated components.

**What it does**:
- Monitors Docker dependencies weekly
- Monitors GitHub Actions dependencies weekly
- Creates automated update pull requests
- Supports dependency alert review through GitHub security features

**Integration**: Configured via `.github/dependabot.yml`

**Usage**:
- Review Dependabot pull requests regularly
- Treat security updates as priority maintenance
- Run tests and security checks before merging updates

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

### Perl::Critic Linter

**Purpose**: Keeps Perl code simple, consistent, and easier to review.

The linter is not a vulnerability scanner, but it supports the security process
by reducing confusing code patterns. Clearer code makes it easier to identify
unsafe file handling, unvalidated input, overly complex logic, and accidental
security regressions during review.

**What it checks**:
- Project style and maintainability rules from `.perlcriticrc`
- Code patterns that make review harder
- Consistency issues across source, target, and test files

**Integration**: Automated linting runs via `.github/workflows/linter.yml`

**Usage**:
- Run `perlcritic --profile .perlcriticrc .` before opening a PR
- Treat linter failures as maintainability and reviewability issues
- Prefer simple code paths for security-sensitive logic

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

### Security Gate

**Purpose**: Provides a centralized CI gate for repository security alerts.

The security gate workflow checks dependency alerts, code alerts, and secret
alerts against strict thresholds. The current configuration allows zero
critical, high, medium, or low findings before the gate fails.

**What it checks**:
- Dependency alerts
- Code scanning alerts
- Secret scanning alerts
- Severity thresholds configured in the workflow

**Integration**: Automated gate runs via `.github/workflows/security-gate.yml`

**Usage**:
- Review failed gate results before merge
- Fix confirmed findings or document false positives
- Keep thresholds strict unless there is a documented temporary exception

### Tests

**Purpose**: Prevents regressions in behavior and security controls.

The project uses tests to verify normal behavior, security-sensitive edge cases,
and integration-level workflows. Tests are especially important when changing
input validation, target loading, dependency behavior, mutation handling, or
threaded execution.

**What it checks**:
- Unit behavior for components
- Security regression cases
- Integration and runtime behavior

**Integration**: Automated testing runs via `.github/workflows/test-on-ubuntu.yml`

**Usage**:
- Run `prove -l tests/` locally for the Perl test suite
- Add regression tests for security fixes
- Confirm dependency updates still pass tests

---

## Automated Security Checks

### CI/CD Integration

Security checks are integrated into the project's continuous integration pipeline:

1. **Dependabot** (`.github/dependabot.yml`): Monitors Docker and GitHub Actions dependencies
2. **Bunkai Workflow** (`bunkai.yml`): Runs SCA analysis and uploads SARIF results
3. **Zarn Workflow** (`zarn.yml`): Runs SAST analysis and uploads SARIF results
4. **Linter Workflow** (`linter.yml`): Runs Perl::Critic to keep code simple and reviewable
5. **Secret Scanning** (`secret-scanning.yml`): Runs TruffleHog on pull requests and pushes
6. **Security Gate Workflow** (`security-gate.yml`): Gates dependency, code, and secret alerts
7. **Testing Workflow** (`test-on-ubuntu.yml`): Runs project validation on Ubuntu

### Workflow Process

1. **On Pull Request**: Linter, SAST, SCA, secret scanning, security gate, and tests run automatically where configured
2. **Results Review**: Maintainers review security scan, lint, and test results
3. **Fix Requirements**: Confirmed security issues must be addressed before merge
4. **False Positives**: False positives must be documented with the reason they are safe
5. **Continuous Monitoring**: Scheduled scans and Dependabot monitoring continue after merge

### Security Gate

The security gate workflow ensures that:

- Dependency alerts stay within the configured threshold
- Code scanning alerts stay within the configured threshold
- Secret scanning alerts stay within the configured threshold
- Confirmed alerts are resolved before merge
- Exceptions are explicit, temporary, and documented

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
2. **Local Checks**: Developer runs tests and Perl::Critic before review
3. **Automated Scans**: CI/CD runs Zarn (SAST), Bunkai (SCA), secret scanning, security gate, linter, and tests
4. **Dependabot Checks**: Dependabot monitors dependency and GitHub Actions updates
5. **Review Results**: Developer and maintainers review scan, lint, and test results
6. **Address Issues**: Fix confirmed security issues before merge
7. **Re-scan**: Verify fixes resolve security concerns
8. **Merge**: Code is merged after security checks pass

### Dependency Management

1. **Dependabot Monitoring**: Weekly monitoring for Docker and GitHub Actions updates
2. **Dependabot PRs**: Review and merge automated dependency update pull requests
3. **Bunkai Scanning**: Automated SCA scanning for dependency risk
4. **Vulnerability Assessment**: Review identified vulnerabilities from multiple sources
5. **Update or Mitigate**: Update dependencies or apply documented mitigations
6. **Testing**: Test dependency updates before merging
7. **Documentation**: Document security-related dependency changes

### Security Maintenance

1. **Regular Scans**: Automated security scans run continuously
2. **Dependency Monitoring**: Dependabot and Bunkai monitor for new vulnerabilities
3. **Secret Monitoring**: Secret scanning continuously checks for exposed credentials
4. **Static Analysis**: Zarn scans source code for security patterns
5. **Linting**: Perl::Critic keeps code understandable and easier to audit
6. **Dependabot PRs**: Regularly review and merge dependency updates
7. **Code Review**: Security-focused code review for all changes
8. **Documentation**: Keep security documentation up to date

---

## Security Best Practices

### For Contributors

- Review security scan results before submitting PRs
- Address security issues identified by automated tools
- Never commit secrets, API keys, or credentials to the repository
- Review and test Dependabot pull requests
- Follow secure coding practices
- Keep dependencies updated
- Report security concerns through the private process in `SECURITY.md`

### For Maintainers

- Review all security scan results
- Respond promptly to Dependabot alerts and PRs
- Address secret scanning alerts immediately
- Prioritize high-severity vulnerabilities
- Ensure security fixes are properly tested
- Coordinate security disclosures
- Maintain security tooling and configurations
- Rotate any exposed secrets immediately
- Keep `SECURITY.md` and this process document current

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
