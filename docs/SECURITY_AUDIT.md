# FuzzPM - Relatório de Auditoria de Segurança

**Data**: 2026-03-06  
**Versão Analisada**: 0.0.4  
**Tipo de Aplicação**: CLI (Command Line Interface)  
**Linguagem**: Perl 5.34+ (testado com 5.34 e 5.42)

---

## Resumo Executivo

Esta auditoria identificou **7 vulnerabilidades de segurança** no código do FuzzPM, sendo:
- **3 vulnerabilidades de Alta Severidade**
- **2 vulnerabilidades de Média Severidade**
- **2 vulnerabilidades de Baixa Severidade**

As principais áreas de preocupação são:
1. Path Traversal permitindo acesso a arquivos arbitrários
2. Carregamento dinâmico de módulos sem validação adequada
3. Falta de sanitização de entradas do usuário
4. Potencial vazamento de dados sensíveis via logging

---

## 🔴 Vulnerabilidades de Alta Severidade

### 1. Path Traversal em Carregamento de Módulos

**Localização**: `lib/FuzzPM/Network/Runner.pm:28-30`

**Código Vulnerável**:
```perl
foreach my $module ( @{ $target_modules } ) {
    my $module_path = "./$module_folder/" . $module . '.pm';
    require $module_path;
}
```

**Risco**: Um atacante pode controlar o conteúdo do arquivo YAML e especificar caminhos como `../../../etc/passwd` ou `../../../../root/.ssh/id_rsa` através dos campos `target_folder` ou `targets`, permitindo:
- Leitura de arquivos sensíveis do sistema
- Execução de código arbitrário via módulos maliciosos
- Bypass de restrições de acesso

**Exemplo de Exploração**:
```yaml
test:
    seeds:
        - seeds/json.txt
    targets:
        - ../../../etc/passwd
    target_folder: ../../../../root
```

**Correção Sugerida**:
```perl
use File::Spec;
use Cwd 'abs_path';

sub _validate_module_path {
    my ($module_name, $base_folder) = @_;
    
    if ($module_name =~ /[^a-zA-Z0-9_]/) {
        croak "Invalid module name: $module_name";
    }
    
    my $base_path = abs_path($base_folder);
    my $module_path = File::Spec->catfile($base_path, "$module_name.pm");
    my $resolved_path = abs_path($module_path);
    
    if (index($resolved_path, $base_path) != 0) {
        croak "Path traversal detected: $module_name";
    }
    
    unless (-f $resolved_path && -r $resolved_path) {
        croak "Module file not found or not readable: $module_name";
    }
    
    return $resolved_path;
}

foreach my $module ( @{ $target_modules } ) {
    my $module_path = _validate_module_path($module, $module_folder);
    require $module_path;
}
```

---

### 2. Path Traversal em Abertura de Arquivos de Seed

**Localização**: `lib/FuzzPM/Network/Runner.pm:35-36`

**Código Vulnerável**:
```perl
foreach my $seed_file ( @{ $seed_files } ) {
    open my $fh, '<', $seed_file or croak "Cannot open file $seed_file: $OS_ERROR";
```

**Risco**: Um atacante pode especificar caminhos relativos ou absolutos no YAML para ler arquivos arbitrários:
- Arquivos de configuração sensíveis
- Chaves privadas SSH
- Histórico de comandos
- Arquivos de banco de dados

**Exemplo de Exploração**:
```yaml
test:
    seeds:
        - ../../../etc/passwd
        - ~/.ssh/id_rsa
        - /etc/shadow
    targets:
        - Json
    target_folder: targets/json
```

**Correção Sugerida**:
```perl
use File::Spec;
use Cwd 'abs_path';

Readonly my $SEEDS_BASE_DIR => abs_path('./seeds');

sub _validate_seed_file {
    my ($seed_file) = @_;
    
    my $resolved_path = abs_path($seed_file);
    
    if (index($resolved_path, $SEEDS_BASE_DIR) != 0) {
        croak "Seed file must be within seeds directory: $seed_file";
    }
    
    unless (-f $resolved_path && -r $resolved_path) {
        croak "Seed file not found or not readable: $seed_file";
    }
    
    return $resolved_path;
}

foreach my $seed_file ( @{ $seed_files } ) {
    my $validated_path = _validate_seed_file($seed_file);
    open my $fh, '<', $validated_path or croak "Cannot open file $validated_path: $OS_ERROR";
```

---

### 3. Carregamento Dinâmico de Módulos sem Validação

**Localização**: `lib/FuzzPM/Network/Runner.pm:30`

**Código Vulnerável**:
```perl
require $module_path;
```

**Risco**: O `require` em Perl executa código Perl arbitrário. Se um atacante conseguir controlar o caminho do módulo ou criar um módulo malicioso no diretório de targets, pode:
- Executar código arbitrário no contexto do processo
- Acessar variáveis de ambiente
- Modificar o sistema de arquivos
- Fazer chamadas de rede
- Escalar privilégios se executado como root

**Correção Sugerida**:
```perl
use Safe;

sub _safe_require_module {
    my ($module_path) = @_;
    
    my $compartment = Safe->new;
    $compartment->permit_only(qw(:default :base_math :base_io));
    $compartment->deny(qw(system exec backtick require do));
    
    local @INC = ($module_folder);
    
    my $module_code = do {
        local $/;
        open my $fh, '<', $module_path or croak "Cannot read module: $module_path";
        <$fh>;
    };
    
    $compartment->reval($module_code) or croak "Error loading module: $@";
}
```

**Nota**: A abordagem com `Safe` pode ser muito restritiva. Uma alternativa mais prática:

```perl
sub _validate_and_load_module {
    my ($module_name, $module_path) = @_;
    
    unless ($module_name =~ /^[A-Za-z][A-Za-z0-9_]*$/) {
        croak "Invalid module name format: $module_name";
    }
    
    my $package_name = $module_name;
    
    {
        no strict 'refs';
        if (defined *{"${package_name}::new"}) {
            croak "Module $package_name already loaded";
        }
    }
    
    my $old_inc = \@INC;
    local @INC = (abs_path($module_folder));
    
    require $module_path;
    
    unless ($package_name->can('new')) {
        croak "Module $package_name does not implement 'new' method";
    }
    
    return 1;
}
```

---

## 🟡 Vulnerabilidades de Média Severidade

### 4. Validação Insuficiente de Entrada do Usuário (Threads)

**Localização**: `lib/FuzzPM/Component/CLI.pm:15` e `lib/FuzzPM/Network/Runner.pm:21`

**Código Vulnerável**:
```perl
't|threads=i' => \$opts{threads},
# ...
$num_threads //= $DEFAULT_NUM_THREADS;
```

**Risco**: 
- Valores negativos ou muito grandes podem causar DoS (Denial of Service)
- Valores extremos podem esgotar recursos do sistema
- Pode causar travamento do sistema em ambientes com recursos limitados

**Exemplo de Exploração**:
```bash
perl fuzzpm.pl --case cases/json-decode.yml --threads 999999
perl fuzzpm.pl --case cases/json-decode.yml --threads -1
```

**Correção Sugerida**:
```perl
sub _validate_thread_count {
    my ($threads) = @_;
    
    return $DEFAULT_NUM_THREADS unless defined $threads;
    
    unless ($threads =~ /^\d+$/) {
        croak "Thread count must be a positive integer";
    }
    
    $threads = int($threads);
    
    if ($threads < 1) {
        croak "Thread count must be at least 1";
    }
    
    my $max_threads = $ENV{FUZZPM_MAX_THREADS} || 64;
    if ($threads > $max_threads) {
        croak "Thread count exceeds maximum ($max_threads)";
    }
    
    my $cpu_count = `nproc` || 1;
    chomp $cpu_count;
    if ($threads > $cpu_count * 4) {
        warn "Warning: Thread count ($threads) is very high compared to CPU cores ($cpu_count)";
    }
    
    return $threads;
}
```

---

### 5. Vazamento de Dados Sensíveis via Logging

**Localização**: `lib/FuzzPM/Network/Runner.pm:67, 96`

**Código Vulnerável**:
```perl
print "[-] Seed\t-> $line\n";
# ...
print '[+] ' . $res -> {module} . "\t" . $res -> {result} . "\n";
```

**Risco**: 
- Seeds podem conter dados sensíveis (tokens, senhas, PII)
- Resultados de módulos podem vazar informações confidenciais
- Logs podem ser capturados por processos de terceiros
- Histórico de comandos pode conter dados sensíveis

**Correção Sugerida**:
```perl
use Readonly;

Readonly my $REDACT_THRESHOLD => 100;

sub _sanitize_output {
    my ($data, $max_length) = @_;
    $max_length //= $REDACT_THRESHOLD;
    
    if (length($data) > $max_length) {
        return substr($data, 0, $max_length) . '... [truncated]';
    }
    
    if ($ENV{FUZZPM_REDACT_SENSITIVE}) {
        $data =~ s/(password|token|secret|key|api[_-]?key)=[^\s&]+/$1=***REDACTED***/gi;
        $data =~ s/(?:Bearer|Authorization):\s*[^\s]+/Authorization: ***REDACTED***/gi;
    }
    
    return $data;
}

lock($OUTPUT_LOCK);
print "[-] Seed\t-> " . _sanitize_output($line) . "\n";
```

**Alternativa**: Adicionar flag `--redact` para modo seguro:
```perl
if ($opts{redact}) {
    $ENV{FUZZPM_REDACT_SENSITIVE} = 1;
}
```

---

## 🟢 Vulnerabilidades de Baixa Severidade

### 6. Falta de Validação de Estrutura YAML

**Localização**: `lib/FuzzPM/Component/Case.pm:19-21`

**Código Vulnerável**:
```perl
my $yaml = YAML::Tiny -> read($file) or croak "Error reading file $file: $OS_ERROR";
return $yaml -> [0] -> {test};
```

**Risco**: 
- YAML malformado pode causar erros não tratados
- Estrutura inesperada pode causar acesso a chaves inexistentes
- Pode causar crash da aplicação

**Correção Sugerida**:
```perl
sub new {
    my ($self, $file) = @_;
    
    unless (defined $file && length $file) {
        croak "Case file path is required";
    }
    
    my $yaml = YAML::Tiny->read($file) or croak "Error reading file $file: $OS_ERROR";
    
    unless (ref $yaml eq 'ARRAY' && @$yaml > 0) {
        croak "Invalid YAML structure: expected array";
    }
    
    my $test_case = $yaml->[0]->{test};
    
    unless (ref $test_case eq 'HASH') {
        croak "Invalid YAML structure: 'test' key not found or not a hash";
    }
    
    unless (exists $test_case->{seeds} && ref $test_case->{seeds} eq 'ARRAY') {
        croak "Invalid YAML structure: 'seeds' must be an array";
    }
    
    unless (exists $test_case->{targets} && ref $test_case->{targets} eq 'ARRAY') {
        croak "Invalid YAML structure: 'targets' must be an array";
    }
    
    unless (@{ $test_case->{targets} } > 0) {
        croak "At least one target module is required";
    }
    
    if (exists $test_case->{target_folder}) {
        unless (defined $test_case->{target_folder} && length $test_case->{target_folder}) {
            croak "target_folder cannot be empty";
        }
    }
    
    return $test_case;
}
```

---

### 7. Race Condition Potencial em Output Lock

**Localização**: `lib/FuzzPM/Network/Runner.pm:66, 93`

**Código Vulnerável**:
```perl
my $OUTPUT_LOCK : shared = 1;

{
    lock($OUTPUT_LOCK);
    print "[-] Seed\t-> $line\n";
}
```

**Risco**: 
- Embora o lock esteja presente, múltiplas operações de print podem ser intercaladas
- Buffer de stdout pode causar saída intercalada
- Baixa severidade, mas pode causar confusão na análise de resultados

**Correção Sugerida**:
```perl
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

_safe_print("[-] Seed\t-> $line\n");
```

---

## 🔧 Melhorias de Configuração e Arquitetura

### 1. Sandboxing de Módulos Target

Implementar um ambiente isolado para execução de módulos target:

```perl
use Safe;
use Opcode;

my $compartment = Safe->new;
$compartment->permit_only(
    qw(:default :base_math),
    qw(require dofile)
);
$compartment->deny(qw(system exec backtick));
```

### 2. Timeout para Execução de Módulos

Adicionar timeout para prevenir módulos que travam:

```perl
use Time::Out qw(timeout);

my $result = timeout 5 => sub {
    return $module->new($line);
} or do {
    warn "Module $module timed out on seed: $line";
    return 0;
};
```

### 3. Validação de Permissões de Arquivo

Verificar permissões antes de abrir arquivos:

```perl
sub _check_file_permissions {
    my ($file) = @_;
    
    my $mode = (stat($file))[2];
    
    if ($mode & 002) {
        warn "Warning: File $file is world-writable";
    }
    
    unless (-r $file) {
        croak "File $file is not readable";
    }
    
    return 1;
}
```

### 4. Limitação de Tamanho de Seed

Prevenir DoS via seeds muito grandes:

```perl
Readonly my $MAX_SEED_SIZE => 10 * 1024 * 1024;

sub _validate_seed_size {
    my ($seed_file) = @_;
    
    my $size = -s $seed_file;
    
    if ($size > $MAX_SEED_SIZE) {
        croak "Seed file $seed_file exceeds maximum size ($MAX_SEED_SIZE bytes)";
    }
    
    return 1;
}
```

### 5. Modo de Execução Seguro

Adicionar flag `--safe-mode` que:
- Desabilita carregamento de módulos fora do diretório base
- Reduz limites de threads
- Habilita redação automática de dados sensíveis
- Adiciona timeouts mais restritivos

---

## 📋 Plano de Ação Prioritário

### Prioridade 1 (Crítico - Implementar Imediatamente)

1. **Implementar validação de caminhos para módulos** (Vulnerabilidade #1)
   - Adicionar função `_validate_module_path()`
   - Usar `File::Spec` e `abs_path()` para normalização
   - Validar que caminhos resolvidos estão dentro do diretório base

2. **Implementar validação de caminhos para seed files** (Vulnerabilidade #2)
   - Restringir seed files ao diretório `seeds/`
   - Validar caminhos absolutos vs relativos
   - Adicionar whitelist de diretórios permitidos

3. **Adicionar validação de nomes de módulos** (Vulnerabilidade #3)
   - Validar formato de nomes de módulos (apenas alfanuméricos e underscore)
   - Verificar existência e legibilidade antes de `require`
   - Considerar uso de `Safe` para isolamento

### Prioridade 2 (Alto - Implementar em 1-2 semanas)

4. **Implementar sanitização de output** (Vulnerabilidade #5)
   - Adicionar função `_sanitize_output()`
   - Implementar flag `--redact` para modo seguro
   - Truncar outputs muito longos

5. **Adicionar validação de thread count** (Vulnerabilidade #4)
   - Validar limites mínimo e máximo
   - Adicionar variável de ambiente `FUZZPM_MAX_THREADS`
   - Adicionar warning para valores muito altos

### Prioridade 3 (Médio - Implementar em 1 mês)

6. **Melhorar validação de YAML** (Vulnerabilidade #6)
   - Validar estrutura completa do YAML
   - Adicionar mensagens de erro mais descritivas
   - Validar tipos de dados esperados

7. **Melhorar thread safety** (Vulnerabilidade #7)
   - Consolidar prints em função única
   - Adicionar flush explícito de stdout

### Prioridade 4 (Baixo - Melhorias Contínuas)

8. **Adicionar sandboxing opcional**
   - Implementar uso de `Safe` para módulos target
   - Adicionar flag `--sandbox` para habilitar

9. **Adicionar timeouts**
   - Implementar timeout para execução de módulos
   - Configurável via variável de ambiente

10. **Adicionar validação de permissões**
    - Verificar permissões de arquivos antes de abrir
    - Adicionar warnings para arquivos world-writable

---

## 🧪 Testes de Segurança Recomendados

1. **Testes de Path Traversal**:
   ```perl
   # Test cases para incluir em tests/security.t
   - ../../../etc/passwd
   - ../../../../root/.ssh/id_rsa
   - /etc/shadow
   - ~/.bash_history
   ```

2. **Testes de Validação de Entrada**:
   ```perl
   - Thread count negativo
   - Thread count muito alto (999999)
   - Nomes de módulos com caracteres especiais
   - YAML malformado
   ```

3. **Testes de Vazamento de Dados**:
   ```perl
   - Seeds contendo tokens/senhas
   - Outputs muito longos
   - Caracteres especiais em seeds
   ```

---

## 📚 Referências e Boas Práticas

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Perl Security Best Practices](https://perldoc.perl.org/perlsec)
- [CWE-22: Path Traversal](https://cwe.mitre.org/data/definitions/22.html)
- [CWE-20: Improper Input Validation](https://cwe.mitre.org/data/definitions/20.html)
- [CWE-209: Information Exposure](https://cwe.mitre.org/data/definitions/209.html)

---

## ✅ Checklist de Implementação

- [ ] Validação de caminhos de módulos
- [ ] Validação de caminhos de seed files
- [ ] Validação de nomes de módulos
- [ ] Sanitização de output
- [ ] Validação de thread count
- [ ] Validação completa de YAML
- [ ] Melhorias de thread safety
- [ ] Testes de segurança
- [ ] Documentação de segurança atualizada
- [ ] Revisão de código por pares

---

**Última Atualização**: 2026-03-06  
**Próxima Revisão Recomendada**: Após implementação das correções de Prioridade 1
