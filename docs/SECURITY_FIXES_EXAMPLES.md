# FuzzPM - Exemplos de Correções de Segurança

Este documento contém exemplos práticos de código corrigido para as vulnerabilidades identificadas na auditoria de segurança.

---

## 1. Validação de Caminhos de Módulos

### Arquivo: `lib/FuzzPM/Network/Runner.pm`

**Antes**:
```perl
foreach my $module ( @{ $target_modules } ) {
    my $module_path = "./$module_folder/" . $module . '.pm';
    require $module_path;
}
```

**Depois**:
```perl
use File::Spec;
use Cwd 'abs_path';

sub _validate_module_path {
    my ($module_name, $base_folder) = @_;
    
    if ($module_name =~ /[^a-zA-Z0-9_]/) {
        croak "Invalid module name: $module_name (only alphanumeric and underscore allowed)";
    }
    
    my $base_path = abs_path($base_folder);
    unless (-d $base_path) {
        croak "Target folder does not exist: $base_folder";
    }
    
    my $module_path = File::Spec->catfile($base_path, "$module_name.pm");
    my $resolved_path = abs_path($module_path);
    
    unless (defined $resolved_path) {
        croak "Cannot resolve path for module: $module_name";
    }
    
    if (index($resolved_path, $base_path) != 0) {
        croak "Path traversal detected in module name: $module_name";
    }
    
    unless (-f $resolved_path && -r $resolved_path) {
        croak "Module file not found or not readable: $module_name (path: $resolved_path)";
    }
    
    return $resolved_path;
}

foreach my $module ( @{ $target_modules } ) {
    my $module_path = _validate_module_path($module, $module_folder);
    require $module_path;
}
```

---

## 2. Validação de Caminhos de Seed Files

### Arquivo: `lib/FuzzPM/Network/Runner.pm`

**Antes**:
```perl
foreach my $seed_file ( @{ $seed_files } ) {
    open my $fh, '<', $seed_file or croak "Cannot open file $seed_file: $OS_ERROR";
```

**Depois**:
```perl
use File::Spec;
use Cwd 'abs_path';

Readonly my $SEEDS_BASE_DIR => abs_path('./seeds');

sub _validate_seed_file {
    my ($seed_file) = @_;
    
    unless (defined $seed_file && length $seed_file) {
        croak "Seed file path cannot be empty";
    }
    
    my $resolved_path = abs_path($seed_file);
    
    unless (defined $resolved_path) {
        croak "Cannot resolve path for seed file: $seed_file";
    }
    
    if (index($resolved_path, $SEEDS_BASE_DIR) != 0) {
        croak "Seed file must be within seeds directory: $seed_file (resolved: $resolved_path)";
    }
    
    unless (-f $resolved_path) {
        croak "Seed file does not exist: $seed_file";
    }
    
    unless (-r $resolved_path) {
        croak "Seed file is not readable: $seed_file";
    }
    
    my $size = -s $resolved_path;
    if ($size > 10 * 1024 * 1024) {
        croak "Seed file exceeds maximum size (10MB): $seed_file";
    }
    
    return $resolved_path;
}

foreach my $seed_file ( @{ $seed_files } ) {
    my $validated_path = _validate_seed_file($seed_file);
    open my $fh, '<', $validated_path or croak "Cannot open file $validated_path: $OS_ERROR";
```

---

## 3. Validação de Thread Count

### Arquivo: `lib/FuzzPM/Component/CLI.pm` e `lib/FuzzPM/Network/Runner.pm`

**Antes**:
```perl
't|threads=i' => \$opts{threads},
# ...
$num_threads //= $DEFAULT_NUM_THREADS;
```

**Depois** (em `CLI.pm`):
```perl
sub new {
    my ($self, %opts) = @_;

    GetOptions (
        'c|case=s'    => \$opts{case},
        'm|mutate'    => \$opts{mutate},
        'h|help'      => \$opts{help},
        't|threads=s' => \$opts{threads},
    );
    
    if (exists $opts{threads}) {
        $opts{threads} = _validate_thread_count($opts{threads});
    }

    return \%opts;
}

sub _validate_thread_count {
    my ($threads) = @_;
    
    unless (defined $threads && $threads =~ /^\d+$/) {
        croak "Thread count must be a positive integer";
    }
    
    $threads = int($threads);
    
    if ($threads < 1) {
        croak "Thread count must be at least 1";
    }
    
    my $max_threads = $ENV{FUZZPM_MAX_THREADS} || 64;
    if ($threads > $max_threads) {
        croak "Thread count ($threads) exceeds maximum ($max_threads). Set FUZZPM_MAX_THREADS to override.";
    }
    
    if ($threads > 100) {
        warn "Warning: Very high thread count ($threads) may cause performance issues\n";
    }
    
    return $threads;
}
```

**Depois** (em `Runner.pm`):
```perl
sub run {
    my ($test_case, $num_threads) = @_;

    $num_threads = _validate_thread_count($num_threads);
    
    # ... rest of code
}

sub _validate_thread_count {
    my ($threads) = @_;
    
    $threads //= $DEFAULT_NUM_THREADS;
    
    unless ($threads =~ /^\d+$/) {
        croak "Thread count must be a positive integer";
    }
    
    $threads = int($threads);
    
    if ($threads < 1) {
        croak "Thread count must be at least 1";
    }
    
    my $max_threads = $ENV{FUZZPM_MAX_THREADS} || 64;
    if ($threads > $max_threads) {
        croak "Thread count ($threads) exceeds maximum ($max_threads)";
    }
    
    return $threads;
}
```

---

## 4. Sanitização de Output

### Arquivo: `lib/FuzzPM/Network/Runner.pm`

**Antes**:
```perl
{
    lock($OUTPUT_LOCK);
    print "[-] Seed\t-> $line\n";
}
# ...
print '[+] ' . $res -> {module} . "\t" . $res -> {result} . "\n";
```

**Depois**:
```perl
Readonly my $MAX_OUTPUT_LENGTH => 500;
Readonly my $REDACT_PATTERNS => [
    qr/(?:password|passwd|pwd)\s*[:=]\s*([^\s&"']+)/i,
    qr/(?:token|api[_-]?key|secret|key)\s*[:=]\s*([^\s&"']+)/i,
    qr/(?:Bearer|Authorization):\s*([^\s]+)/i,
    qr/(?:email|e-mail)\s*[:=]\s*([^\s&"']+)/i,
];

sub _sanitize_output {
    my ($data, $redact) = @_;
    $redact //= $ENV{FUZZPM_REDACT_SENSITIVE} || 0;
    
    return '' unless defined $data;
    
    if (length($data) > $MAX_OUTPUT_LENGTH) {
        $data = substr($data, 0, $MAX_OUTPUT_LENGTH) . '... [truncated]';
    }
    
    if ($redact) {
        foreach my $pattern (@$REDACT_PATTERNS) {
            $data =~ s/$pattern/$1 = ***REDACTED***/g;
        }
    }
    
    $data =~ s/[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]//g;
    
    return $data;
}

sub _safe_print {
    my (@lines) = @_;
    
    {
        lock($OUTPUT_LOCK);
        foreach my $line (@lines) {
            print $line;
        }
        STDOUT->flush();
    }
}

_safe_print('[+] ' . $res->{module} . "\t" . _sanitize_output($res->{result}) . "\n");
```

---

## 5. Validação Completa de YAML

### Arquivo: `lib/FuzzPM/Component/Case.pm`

**Antes**:
```perl
my $yaml = YAML::Tiny -> read($file) or croak "Error reading file $file: $OS_ERROR";
return $yaml -> [0] -> {test};
```

**Depois**:
```perl
sub new {
    my ($self, $file) = @_;
    
    unless (defined $file && length $file) {
        croak "Case file path is required";
    }
    
    unless (-f $file && -r $file) {
        croak "Case file does not exist or is not readable: $file";
    }
    
    my $yaml = YAML::Tiny->read($file) or croak "Error reading file $file: $OS_ERROR";
    
    unless (ref $yaml eq 'ARRAY' && @$yaml > 0) {
        croak "Invalid YAML structure: expected non-empty array";
    }
    
    my $test_case = $yaml->[0]->{test};
    
    unless (ref $test_case eq 'HASH') {
        croak "Invalid YAML structure: 'test' key not found or not a hash";
    }
    
    unless (exists $test_case->{seeds}) {
        croak "Invalid YAML structure: 'seeds' key is required";
    }
    
    unless (ref $test_case->{seeds} eq 'ARRAY' && @{ $test_case->{seeds} } > 0) {
        croak "Invalid YAML structure: 'seeds' must be a non-empty array";
    }
    
    unless (exists $test_case->{targets}) {
        croak "Invalid YAML structure: 'targets' key is required";
    }
    
    unless (ref $test_case->{targets} eq 'ARRAY' && @{ $test_case->{targets} } > 0) {
        croak "Invalid YAML structure: 'targets' must be a non-empty array";
    }
    
    foreach my $target (@{ $test_case->{targets} }) {
        unless (defined $target && length $target) {
            croak "Invalid YAML structure: target name cannot be empty";
        }
        if ($target =~ /[^a-zA-Z0-9_]/) {
            croak "Invalid target name: $target (only alphanumeric and underscore allowed)";
        }
    }
    
    if (exists $test_case->{target_folder}) {
        unless (defined $test_case->{target_folder} && length $test_case->{target_folder}) {
            croak "target_folder cannot be empty if specified";
        }
        if ($test_case->{target_folder} =~ /\.\./) {
            croak "target_folder cannot contain '..' (path traversal not allowed)";
        }
    }
    
    return $test_case;
}
```

---

## 6. Melhorias de Thread Safety

### Arquivo: `lib/FuzzPM/Network/Runner.pm`

**Antes**:
```perl
{
    lock($OUTPUT_LOCK);
    print "[-] Seed\t-> $line\n";
}
```

**Depois**:
```perl
sub _safe_print {
    my (@lines) = @_;
    
    {
        lock($OUTPUT_LOCK);
        foreach my $line (@lines) {
            print $line;
        }
        if (defined fileno(STDOUT)) {
            STDOUT->flush();
        }
    }
}

# Usage:
_safe_print("[-] Seed\t-> " . _sanitize_output($line) . "\n");
```

---

## 7. Adicionar Flag --redact no CLI

### Arquivo: `lib/FuzzPM/Component/CLI.pm`

**Adicionar**:
```perl
sub new {
    my ($self, %opts) = @_;

    GetOptions (
        'c|case=s'    => \$opts{case},
        'm|mutate'    => \$opts{mutate},
        'h|help'      => \$opts{help},
        't|threads=s' => \$opts{threads},
        'r|redact'    => \$opts{redact},
    );
    
    if ($opts{redact}) {
        $ENV{FUZZPM_REDACT_SENSITIVE} = 1;
    }
    
    # ... rest of validation
    
    return \%opts;
}
```

---

## 8. Atualização do cpanfile

Adicionar dependências necessárias:

```perl
requires 'YAML::Tiny',      '1.76';
requires 'List::MoreUtils', '0.430';
requires 'Getopt::Long',    '2.58';
requires 'Readonly';
requires 'Try::Tiny';
requires 'File::Spec',      '3.75';
requires 'Cwd',              '3.75';

on 'test' => sub {
    requires 'File::Temp',          '0.2311';
    requires 'FindBin',             '1.54';
    requires 'Test::More',          '1.302183';
}
```

---

## 10. Documentação de Uso Seguro

Adicionar ao `README.md`:

~~~markdown
## 🔒 Modo Seguro

Para execução em ambientes com dados sensíveis, use a flag `--redact`:

~~~bash
perl fuzzpm.pl --case cases/json-decode.yml --redact
~~~

Isso irá:
- Redigir automaticamente tokens, senhas e chaves API nos outputs
- Truncar outputs muito longos
- Adicionar validações extras de segurança

### Limites de Segurança

- Thread count máximo: 64 (configurável via `FUZZPM_MAX_THREADS`)
- Tamanho máximo de seed file: 10MB
- Seed files devem estar dentro do diretório `seeds/`
- Módulos target devem estar dentro do diretório especificado em `target_folder`
~~~

---

## Checklist de Implementação

- [ ] Adicionar `use File::Spec` e `use Cwd 'abs_path'` em `Runner.pm`
- [ ] Implementar `_validate_module_path()`
- [ ] Implementar `_validate_seed_file()`
- [ ] Implementar `_validate_thread_count()` em `CLI.pm` e `Runner.pm`
- [ ] Implementar `_sanitize_output()` e `_safe_print()`
- [ ] Melhorar validação em `Case.pm`
- [ ] Adicionar flag `--redact` em `CLI.pm`
- [ ] Criar arquivo `tests/security.t`
- [ ] Atualizar `cpanfile` com novas dependências
- [ ] Atualizar documentação no `README.md`
- [ ] Executar testes: `prove -l tests/security.t`
- [ ] Executar todos os testes: `prove -l tests/`
