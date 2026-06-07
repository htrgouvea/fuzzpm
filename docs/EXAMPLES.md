# FuzzPM Examples and Use Cases

This document provides practical examples and use cases for FuzzPM.

---

## Table of Contents

- [Basic Examples](#basic-examples)
- [Advanced Use Cases](#advanced-use-cases)
- [Common Patterns](#common-patterns)

---

## Basic Examples

### Example 1: Testing JSON Parsers

**Scenario**: Compare multiple JSON parsing libraries for consistency.

**Seed File** (`seeds/json.txt`):
```
{"name": "test", "value": 123}
{"array": [1, 2, 3]}
{"nested": {"key": "value"}}
```

**Test Case** (`cases/json-decode.yml`):
```yaml
test:
    seeds:
        - seeds/json.txt
    targets:
        - JsonOn
        - JsonParse
        - Json
        - MojoJson
    target_folder: targets/json
```

**Run**:
```bash
perl fuzzpm.pl --case cases/json-decode.yml
```

**Expected Output** (if divergence found):
```
[-] Seed    -> {"name": "test", "value": 123}
[+] Json    {"name":"test","value":123}
[+] MojoJson {"name":"test","value":123}
[+] JsonParse {"name":"test","value":123}
```

---

### Example 2: Testing URL Parsers

**Scenario**: Find inconsistencies in URL parsing across libraries.

**Seed File** (`seeds/urls.txt`):
```
https://example.com/path?query=value
http://user:pass@host:8080/path
ftp://ftp.example.com/file.txt
```

**Test Case** (`cases/parsing-url.yml`):
```yaml
test:
    seeds:
        - seeds/urls.txt
    targets:
        - MojoUri
        - MojoUa
        - Mechanize
        - SimpleUri
    target_folder: targets/url
```

**Run with Custom Threads**:
```bash
perl fuzzpm.pl --case cases/parsing-url.yml --threads 8
```

---

## Advanced Use Cases

### Example 5: Large-Scale Fuzzing

**Scenario**: Test with thousands of seeds using multiple threads.

**Generate Large Seed File**:
```bash
# Generate 10000 random JSON objects
perl -e 'for (1..10000) { print qq({"id":$_,"data":"test$_"}\n) }' > seeds/large-json.txt
```

**Run with High Thread Count**:
```bash
perl fuzzpm.pl --case cases/json-decode.yml --threads 16
```

**Monitor Progress**: Output will show seeds being processed in real-time.

---

### Example 6: Comparing Output Formats

**Scenario**: Some modules return formatted output, others return raw data.

**Target Module** (`targets/format/Pretty.pm`):
```perl
package Pretty {
    use strict;
    use warnings;
    use Try::Tiny;
    use JSON;

    sub new {
        my ($self, $payload) = @_;
        try {
            my $json = JSON->new->pretty;
            my $data = $json->decode($payload);
            return $json->encode($data);
        }
        catch {
            return 0;
        }
    }
}

1;
```

**Target Module** (`targets/format/Compact.pm`):
```perl
package Compact {
    use strict;
    use warnings;
    use Try::Tiny;
    use JSON;

    sub new {
        my ($self, $payload) = @_;
        try {
            my $json = JSON->new;
            my $data = $json->decode($payload);
            return $json->encode($data);
        }
        catch {
            return 0;
        }
    }
}

1;
```

**Note**: These will show divergences due to formatting differences, which may be expected behavior.

---

## Common Patterns

### Pattern 1: Error Handling

All target modules should handle errors gracefully:

```perl
sub new {
    my ($self, $payload) = @_;
    
    try {
        # Processing that may fail
        my $result = process($payload);
        return $result;
    }
    catch {
        # Return 0 to signal error
        return 0;
    }
}
```

### Pattern 2: Normalizing Output

To reduce false positives from formatting differences:

```perl
sub new {
    my ($self, $payload) = @_;
    
    try {
        my $result = process($payload);
        # Normalize: remove whitespace, lowercase, etc.
        $result =~ s/\s+//g;
        $result = lc($result);
        return $result;
    }
    catch {
        return 0;
    }
}
```

### Pattern 3: Multiple Return Types

Handle different return types consistently:

```perl
sub new {
    my ($self, $payload) = @_;
    
    try {
        my $result = process($payload);
        
        # Convert to string for comparison
        if (ref $result) {
            return $result->to_string;
        }
        
        return $result // 0;
    }
    catch {
        return 0;
    }
}
```

---

## Troubleshooting Examples

### Issue: No Divergences Found

**Problem**: All modules return identical results.

**Solution**: 
- Verify seeds are valid and diverse
- Check that modules are actually processing inputs
- Try edge cases and malformed inputs

### Issue: Too Many Divergences

**Problem**: Modules have different output formats.

**Solution**: Normalize outputs in target modules (see Pattern 2 above).

### Issue: Module Fails to Load

**Problem**: `require` fails for target module.

**Checklist**:
- [ ] Filename matches package name exactly
- [ ] File ends with `1;`
- [ ] Dependencies installed (`cpanm --installdeps .` and `cpanm --installdeps targets/<category>`)
- [ ] File path correct in YAML

---

## Best Practices

1. **Start Small**: Begin with simple test cases and few seeds
2. **Incremental Testing**: Add complexity gradually
3. **Document Divergences**: Keep notes on expected vs. unexpected divergences
4. **Version Control**: Track seed files and test cases in git
5. **Regular Updates**: Update seeds with new edge cases regularly

---

## Further Reading

- [Architecture Documentation](ARCHITECTURE.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Main README](../README.md)
