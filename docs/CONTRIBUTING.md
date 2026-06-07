# Contributing to FuzzPM

Thank you for your interest in contributing to FuzzPM! This document provides guidelines and instructions for contributing to the project.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Submitting Changes](#submitting-changes)
- [Testing](#testing)
- [Documentation](#documentation)
- [Project Structure](#project-structure)

---

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors. Be kind, considerate, and constructive in all interactions.

---

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/fuzzpm.git
   cd fuzzpm
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/htrgouvea/fuzzpm.git
   ```
4. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

---

## Development Setup

### Prerequisites

- Perl 5.34+ (tested with 5.34 and 5.42)
- `cpanm` (Perl module installer)
- Git

### Installation

```bash
# Install core dependencies
cpanm --installdeps .

# Install target-specific dependencies
cpanm --installdeps targets/json
cpanm --installdeps targets/url
cpanm --installdeps targets/email
```

### Running Tests

```bash
# Run all tests
prove -l tests/

# Run specific test file
prove -l tests/case.t

# Run with verbose output
prove -lv tests/
```

### Code Quality Checks

```bash
# Run perlcritic
perlcritic .

# Run with specific severity level
perlcritic --severity 3 .

# Check specific file
perlcritic lib/FuzzPM/Component/CLI.pm
```

---

## Coding Standards

### Perl Style Guide

FuzzPM follows Perl Best Practices (PBP) where applicable:

1. **Package Names**: Must match filename exactly (case-sensitive)
   ```perl
   package MyModule {  # File: MyModule.pm
   ```

2. **Indentation**: 4 spaces (no tabs)

3. **Line Length**: Prefer lines under 80 characters when possible

4. **Naming Conventions**:
   - Packages: `PascalCase` (e.g., `FuzzPM::Component::CLI`)
   - Subroutines: `snake_case` (e.g., `new`, `run`)
   - Variables: `snake_case` (e.g., `$test_case`, `$num_threads`)

5. **Code Organization**:
   ```perl
   package MyPackage {
       use strict;
       use warnings;
       use Other::Module;
       
       our $VERSION = '0.0.1';
       
       sub new {
           # Implementation
       }
   }
   
   1;
   ```

6. **Error Handling**: Use `Try::Tiny` for exception handling:
   ```perl
   use Try::Tiny;
   
   try {
       # Code that may fail
   }
   catch {
       # Error handling
   }
   ```

7. **Documentation**: Add POD comments for public methods:
   ```perl
   =head2 new
   
   Creates a new instance.
   
   =cut
   ```

### File Structure

- **No trailing whitespace**
- **Unix line endings** (LF)
- **End files with newline**
- **No comments** (per project preference, unless necessary)

### Git Commit Messages

Follow conventional commit format:

```
type(scope): subject

body (optional)

footer (optional)
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test additions/changes
- `refactor`: Code refactoring
- `style`: Code style changes
- `chore`: Maintenance tasks

**Examples**:
```
feat(runner): add support for custom output formats

fix(cli): correct thread count validation

docs(readme): update installation instructions
```

---

## Submitting Changes

### Pull Request Process

1. **Update your branch**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Ensure tests pass**:
   ```bash
   prove -l tests/
   ```

3. **Check code quality**:
   ```bash
   perlcritic .
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat(component): add new feature"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create Pull Request** on GitHub:
   - Provide clear description of changes
   - Reference any related issues
   - Include examples if adding new features

### Pull Request Guidelines

- **One feature per PR**: Keep changes focused and reviewable
- **Update documentation**: If adding features, update relevant docs
- **Add tests**: New features should include tests
- **Pass CI**: All CI checks must pass
- **Respond to feedback**: Address review comments promptly

---

## Testing

### Writing Tests

Tests use `Test::More` and follow this structure:

```perl
#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 1;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Your::Module;

# Test code here
is($result, $expected, 'Test description');
```

### Test Coverage

- **Unit tests**: Test individual components in isolation
- **Integration tests**: Test component interactions
- **Edge cases**: Test error conditions and boundary cases

### Running Tests

```bash
# All tests
prove -l tests/

# Specific test
prove -l tests/your_test.t

# With coverage (if configured)
cover -test
```

---

## Documentation

### Code Documentation

- Add POD comments for public methods
- Document parameters and return values
- Include usage examples for complex functions

### User Documentation

- Update `README.md` for user-facing changes
- Add examples for new features
- Update troubleshooting section if needed

### Technical Documentation

- Update `docs/ARCHITECTURE.md` for architectural changes
- Document new components and their interactions
- Update dependency information

---

## Project Structure

### Directory Layout

```
fuzzpm/
├── cases/              # YAML test case definitions
├── docs/               # Documentation
│   ├── ARCHITECTURE.md
│   └── CONTRIBUTING.md
├── lib/                # Core modules
│   └── FuzzPM/
│       ├── Component/  # CLI, Case, Mutator
│       └── Network/     # Runner
├── seeds/              # Seed files
├── targets/            # Target modules
│   ├── email/
│   ├── json/
│   └── url/
├── tests/              # Test suite
├── cpanfile           # Dependencies
└── fuzzpm.pl          # Entry point
```

### Adding New Components

1. **Create module** in appropriate directory:
   - Components: `lib/FuzzPM/Component/`
   - Network: `lib/FuzzPM/Network/`

2. **Follow naming convention**: Match package to filename

3. **Add tests**: Create corresponding test file in `tests/`

4. **Update documentation**: Document in `docs/ARCHITECTURE.md`

### Adding New Targets

1. **Create target module** in `targets/<category>/`
2. **Follow target interface**: Implement `new($payload)` method
3. **Add dependencies**: Update `targets/<category>/cpanfile`
4. **Create test case**: Add YAML file in `cases/`
5. **Add seeds**: Create seed file in `seeds/`

---

## Areas for Contribution

### High Priority

- [ ] Improve error messages and diagnostics
- [ ] Add support for output formats (JSON, CSV)
- [ ] Enhance seed mutation strategies
- [ ] Add progress indicators for long-running tests
- [ ] Improve thread safety documentation

### Medium Priority

- [ ] Add more target modules
- [ ] Create example test cases
- [ ] Performance optimizations
- [ ] CI/CD improvements
- [ ] Documentation enhancements

### Low Priority

- [ ] GUI or web interface
- [ ] Result analysis tools
- [ ] Integration with other fuzzing tools
- [ ] Support for other languages (experimental)

---

## Getting Help

- **Issues**: Open an issue on GitHub for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Security**: See [SECURITY.md](../SECURITY.md) for security issues

---

## Recognition

Contributors will be recognized in:
- `README.md` (if significant contributions)
- Release notes
- GitHub contributors page

---

## License

By contributing, you agree that your contributions will be licensed under the same MIT License as the project.

---

Thank you for contributing to FuzzPM! 🎉
