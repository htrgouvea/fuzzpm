# FuzzPM Architecture Documentation

This document provides a detailed technical overview of FuzzPM's architecture, components, and internal workings.

---

## Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Core Components](#core-components)
- [Execution Flow](#execution-flow)
- [Threading Model](#threading-model)
- [Module System](#module-system)
- [Dependencies](#dependencies)

---

## Overview

FuzzPM is built as a modular Perl application that implements differential fuzzing through a multi-threaded execution model. The system is designed to be extensible, allowing users to easily add new target modules and test cases.

### Key Design Principles

1. **Modularity**: Core functionality is separated into distinct components
2. **Extensibility**: Easy to add new targets without modifying core code
3. **Performance**: Multi-threaded execution for efficient fuzzing
4. **Simplicity**: YAML-based configuration for ease of use

---

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    fuzzpm.pl                            │
│              (Main Entry Point)                         │
└──────────────────┬──────────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
┌───────▼────────┐   ┌────────▼──────────┐
│  CLI Component │   │  Case Component   │
│  (Options)     │   │  (YAML Parser)    │
└───────┬────────┘   └────────┬──────────┘
        │                     │
        └──────────┬──────────┘
                   │
        ┌──────────▼──────────┐
        │   Network::Runner    │
        │  (Thread Manager)    │
        └──────────┬───────────┘
                   │
        ┌──────────▼───────────┐
        │   Worker Threads      │
        │  (Parallel Execution) │
        └──────────┬────────────┘
                   │
        ┌──────────▼────────────┐
        │   Target Modules      │
        │  (User-defined)      │
        └───────────────────────┘
```

---

## Core Components

### 1. FuzzPM::Component::CLI

**Location**: `lib/FuzzPM/Component/CLI.pm`

**Purpose**: Parses and validates command-line arguments.

**Key Methods**:
- `new()` - Parses command-line options using `Getopt::Long`

**Options Handled**:
- `--case` / `-c`: Path to YAML test case file
- `--threads` / `-t`: Number of threads (integer)
- `--mutate` / `-m`: Enable seed mutation (experimental)
- `--mutate-times`: Number of mutations to run per seed (implies `--mutate`)
- `--show-matches` / `-s`: Print target output even when they agree
- `--help` / `-h`: Display help message

**Returns**: Hash reference with parsed options

---

### 2. FuzzPM::Component::Case

**Location**: `lib/FuzzPM/Component/Case.pm`

**Purpose**: Loads and parses YAML test case files.

**Key Methods**:
- `new($file)` - Reads and parses YAML file, returns test case structure

**Test Case Structure**:
```perl
{
    seeds         => ['seeds/file1.txt', 'seeds/file2.txt'],
    targets       => ['Module1', 'Module2'],
    target_folder => 'targets/category'
}
```

**Dependencies**: `YAML::Tiny` for YAML parsing

---

### 3. FuzzPM::Network::Runner

**Location**: `lib/FuzzPM/Network/Runner.pm`

**Purpose**: Manages the fuzzing execution, thread creation, and result comparison.

**Key Methods**:
- `new($case_packet_or_test_case, @legacy_args)` - Main entry point for fuzzing execution
- `_validate_limited_integer($label, $value, $minimum, $maximum)` - Validates thread and mutation limits

**Responsibilities**:
1. Normalize packet or legacy runner inputs
2. Validate thread and mutation limits
3. Load target modules dynamically
4. Read seed files and populate thread queue
5. Create and manage worker threads
6. Aggregate worker statistics

**Threading**:
- Uses Perl's `threads` module
- `Thread::Queue` for thread-safe seed distribution
- `threads::shared` for shared output lock

**Default Configuration**:
- Default thread count: 4
- Maximum thread count: 64, override with `FUZZPM_MAX_THREADS`
- Maximum mutations per seed: 1024, override with `FUZZPM_MAX_MUTATIONS`
- Shared output lock for synchronized printing

---

### 4. FuzzPM::Component::Mutator

**Location**: `lib/FuzzPM/Component/Mutator.pm`

**Purpose**: Provides seed mutation functionality (experimental).

**Key Methods**:
- `new($seed)` - Mutates a seed string using Radamsa

**Algorithm**: Uses the CPAN `Radamsa` binding with a bounded output size

**Status**: Experimental feature used when mutation is enabled (`--mutate` or `--mutate-times`)

---

## Execution Flow

### Program Flow Diagram

The following diagram illustrates the complete execution flow of FuzzPM from startup to completion:

```mermaid
flowchart TD
    Start([fuzzpm.pl starts]) --> CLI[CLI::new<br/>Parse command-line arguments]
    CLI --> CheckHelp{Help requested<br/>or no case?}
    CheckHelp -->|Yes| ShowHelp[Display help message]
    ShowHelp --> End1([Exit])
    CheckHelp -->|No| CaseLoad[Case::new<br/>Load YAML test case]
    
    CaseLoad --> ParseYAML[Parse YAML file<br/>Validate seeds, targets, folder]
    ParseYAML --> Runner[Runner::new<br/>Initialize fuzzing]
    
    Runner --> LoadModules[Load Target Modules<br/>require each module from target_folder]
    LoadModules --> CreateQueue[Create Thread::Queue<br/>Initialize seed queue]
    
    CreateQueue --> ReadSeeds[Read Seed Files<br/>For each seed file]
    ReadSeeds --> ReadLine[Read line from file<br/>One seed per line]
    ReadLine --> Enqueue[Enqueue seed to queue]
    Enqueue --> MoreSeeds{More lines<br/>in file?}
    MoreSeeds -->|Yes| ReadLine
    MoreSeeds -->|No| MoreFiles{More seed<br/>files?}
    MoreFiles -->|Yes| ReadSeeds
    MoreFiles -->|No| EndQueue[Mark queue as ended]
    
    EndQueue --> CreateThreads[Create Worker Threads<br/>Spawn N threads default: 4]
    CreateThreads --> Thread1[Worker Thread 1]
    CreateThreads --> Thread2[Worker Thread 2]
    CreateThreads --> ThreadN[Worker Thread N]
    
    Thread1 --> WorkerLoop1[Worker Loop]
    Thread2 --> WorkerLoop2[Worker Loop]
    ThreadN --> WorkerLoopN[Worker Loop]
    
    WorkerLoop1 --> Dequeue1[Dequeue seed from queue]
    WorkerLoop2 --> Dequeue2[Dequeue seed from queue]
    WorkerLoopN --> DequeueN[Dequeue seed from queue]
    
    Dequeue1 --> CheckEmpty1{Queue<br/>empty?}
    Dequeue2 --> CheckEmpty2{Queue<br/>empty?}
    DequeueN --> CheckEmptyN{Queue<br/>empty?}
    
    CheckEmpty1 -->|Yes| ThreadExit1[Thread exits]
    CheckEmpty2 -->|Yes| ThreadExit2[Thread exits]
    CheckEmptyN -->|Yes| ThreadExitN[Thread exits]
    
    CheckEmpty1 -->|No| ProcessSeed1[Process Seed]
    CheckEmpty2 -->|No| ProcessSeed2[Process Seed]
    CheckEmptyN -->|No| ProcessSeedN[Process Seed]
    
    ProcessSeed1 --> PrintSeed1[Print seed with lock<br/>[-] Seed -> input]
    ProcessSeed2 --> PrintSeed2[Print seed with lock<br/>[-] Seed -> input]
    ProcessSeedN --> PrintSeedN[Print seed with lock<br/>[-] Seed -> input]
    
    PrintSeed1 --> ExecuteModules1[Execute Target Modules<br/>For each target module]
    PrintSeed2 --> ExecuteModules2[Execute Target Modules<br/>For each target module]
    PrintSeedN --> ExecuteModulesN[Execute Target Modules<br/>For each target module]
    
    ExecuteModules1 --> Module1_1[Module1::new seed]
    ExecuteModules1 --> Module2_1[Module2::new seed]
    ExecuteModules1 --> ModuleN_1[ModuleN::new seed]
    
    ExecuteModules2 --> Module1_2[Module1::new seed]
    ExecuteModules2 --> Module2_2[Module2::new seed]
    ExecuteModules2 --> ModuleN_2[ModuleN::new seed]
    
    ExecuteModulesN --> Module1_N[Module1::new seed]
    ExecuteModulesN --> Module2_N[Module2::new seed]
    ExecuteModulesN --> ModuleN_N[ModuleN::new seed]
    
    Module1_1 --> CollectResults1[Collect Results<br/>Store module outputs]
    Module2_1 --> CollectResults1
    ModuleN_1 --> CollectResults1
    
    Module1_2 --> CollectResults2[Collect Results<br/>Store module outputs]
    Module2_2 --> CollectResults2
    ModuleN_2 --> CollectResults2
    
    Module1_N --> CollectResultsN[Collect Results<br/>Store module outputs]
    Module2_N --> CollectResultsN
    ModuleN_N --> CollectResultsN
    
    CollectResults1 --> Compare1{Results<br/>diverge?}
    CollectResults2 --> Compare2{Results<br/>diverge?}
    CollectResultsN --> CompareN{Results<br/>diverge?}
    
    Compare1 -->|Yes| PrintDiv1[Print divergences with lock<br/>[+] Module output]
    Compare1 -->|No| WorkerLoop1
    Compare2 -->|Yes| PrintDiv2[Print divergences with lock<br/>[+] Module output]
    Compare2 -->|No| WorkerLoop2
    CompareN -->|Yes| PrintDivN[Print divergences with lock<br/>[+] Module output]
    CompareN -->|No| WorkerLoopN
    
    PrintDiv1 --> WorkerLoop1
    PrintDiv2 --> WorkerLoop2
    PrintDivN --> WorkerLoopN
    
    ThreadExit1 --> JoinThreads[Main thread joins all workers]
    ThreadExit2 --> JoinThreads
    ThreadExitN --> JoinThreads
    
    JoinThreads --> Complete([Execution Complete])
    
    style Start fill:#e1f5e1
    style Complete fill:#e1f5e1
    style End1 fill:#ffe1e1
    style Thread1 fill:#e1e5ff
    style Thread2 fill:#e1e5ff
    style ThreadN fill:#e1e5ff
    style CreateQueue fill:#fff4e1
    style Compare1 fill:#ffe1e1
    style Compare2 fill:#ffe1e1
    style CompareN fill:#ffe1e1
```

### Simplified Sequential Flow

For a high-level view of the sequential execution phases:

```mermaid
sequenceDiagram
    participant User
    participant Main as fuzzpm.pl
    participant CLI as CLI Component
    participant Case as Case Component
    participant Runner as Network::Runner
    participant Queue as Thread::Queue
    participant Worker1 as Worker Thread 1
    participant Worker2 as Worker Thread 2
    participant Module1 as Target Module 1
    participant Module2 as Target Module 2
    
    User->>Main: Execute with --case file.yml
    Main->>CLI: Parse arguments
    CLI-->>Main: Return options hash
    Main->>Case: Load YAML file
    Case-->>Main: Return test case data
    Main->>Runner: new(case_packet)
    
    Runner->>Runner: Normalize and validate options
    Runner->>Runner: Load target modules
    Runner->>Queue: Create queue
    Runner->>Queue: Enqueue seeds from files
    Runner->>Queue: Mark queue ended
    
    Runner->>Worker1: Create thread
    Runner->>Worker2: Create thread
    
    par Parallel Processing
        Worker1->>Queue: Dequeue seed
        Queue-->>Worker1: Return seed
        Worker1->>Module1: new(seed)
        Worker1->>Module2: new(seed)
        Module1-->>Worker1: Result 1
        Module2-->>Worker1: Result 2
        Worker1->>Worker1: Compare results
        alt Divergence found
            Worker1->>Main: Print divergence
        end
    and
        Worker2->>Queue: Dequeue seed
        Queue-->>Worker2: Return seed
        Worker2->>Module1: new(seed)
        Worker2->>Module2: new(seed)
        Module1-->>Worker2: Result 1
        Module2-->>Worker2: Result 2
        Worker2->>Worker2: Compare results
        alt Divergence found
            Worker2->>Main: Print divergence
        end
    end
    
    Worker1-->>Runner: Thread complete
    Worker2-->>Runner: Thread complete
    Runner->>Runner: Join all threads
    Runner-->>Main: Return success
    Main-->>User: Execution complete
```

### Step-by-Step Process

1. **Initialization** (`fuzzpm.pl`)
   - Parse command-line arguments via `CLI::new()`
   - Validate required options (--case)
   - Display help if requested

2. **Case Loading** (`Case::new()`)
   - Read YAML test case file
   - Parse structure into Perl hash
   - Return test case configuration

3. **Module Loading** (`Runner::new()`)
   - Iterate through target modules
   - Dynamically `require` each module from `target_folder`
   - Modules must be in format: `./target_folder/ModuleName.pm`
   - `target_folder` and module file paths must resolve inside `targets/`

4. **Seed Queue Population**
   - Open each seed file
   - Read lines (one seed per line)
   - Enqueue seeds into `Thread::Queue`
   - Mark queue as ended

5. **Thread Creation**
   - Create `$num_threads` worker threads
   - Each thread receives: queue reference, target modules array

6. **Worker Execution** (`Runner::Worker::new()`)
   - Dequeue seeds from queue
   - For each seed:
     - Print seed being processed (with lock)
     - Execute each target module with seed
     - Collect results from all modules
     - Compare results for divergence
     - Print divergences if found

7. **Thread Synchronization**
   - Main thread waits for all workers to complete
   - Workers exit when queue is empty

8. **Completion**
   - Return success status

---

## Threading Model

### Thread Safety

FuzzPM uses several mechanisms to ensure thread safety:

1. **Thread::Queue**: Thread-safe queue for seed distribution
   - Workers dequeue seeds atomically
   - No race conditions in seed access

2. **Shared Lock**: `$OUTPUT_LOCK` (shared variable)
   - Synchronizes output printing
   - Prevents interleaved output from multiple threads

3. **Module Isolation**: Each target module is loaded once
   - Modules should be stateless or thread-safe
   - No shared state between module instances

### Thread Lifecycle

```
Main Thread                    Worker Threads
    │                               │
    ├─ Create Queue                 │
    ├─ Populate Queue               │
    ├─ Create Threads ──────────────┼─ Start
    │                               ├─ Dequeue Seed
    ├─ Wait (join)                  ├─ Process with Targets
    │                               ├─ Compare Results
    │                               ├─ Print Divergences
    │                               ├─ Loop until queue empty
    │                               └─ Exit
    └─ Complete
```

---

## Module System

### Target Module Requirements

Target modules must follow a specific interface:

1. **Package Declaration**: Must match filename exactly
   ```perl
   package MyModule {  # File: MyModule.pm
   ```

2. **Constructor**: Must implement `new($payload)` method
   ```perl
   sub new {
       my ($self, $payload) = @_;
       # Process $payload
       return $result;  # or 0 on error
   }
   ```

3. **Error Handling**: Should use `Try::Tiny` for exception handling
   ```perl
   use Try::Tiny;
   
   try {
       # Processing
       return $result;
   }
   catch {
       return 0;  # Signal error
   }
   ```

4. **Return Values**:
   - Success: Return processed result (string/number)
   - Failure: Return `0` or `undef`

### Module Loading

Modules are loaded dynamically at runtime:

```perl
foreach my $module (@target_modules) {
    my $module_path = "./$module_folder/" . $module . '.pm';
    require $module_path;
}
```

**Important**: Module names in YAML must match:
- Filename (without `.pm`)
- Package name (exactly)

---

## Dependencies

### Core Dependencies

| Module | Purpose | Version |
|--------|---------|---------|
| `YAML::Tiny` | YAML parsing | 1.76+ |
| `List::MoreUtils` | List utilities | 0.430+ |
| `Getopt::Long` | CLI parsing | 2.58+ |
| `Readonly` | Immutable variables | latest |
| `Try::Tiny` | Exception handling | latest |

### Threading Dependencies

| Module | Purpose | Status |
|--------|---------|--------|
| `threads` | Thread creation | Core Perl |
| `Thread::Queue` | Thread-safe queues | Core Perl |
| `threads::shared` | Shared variables | Core Perl |

### Test Dependencies

| Module | Purpose | Version |
|--------|---------|---------|
| `Test::More` | Testing framework | Core Perl |
| `File::Temp` | Temporary files | 0.2311+ |
| `FindBin` | Find script directory | 1.54+ |

### Target-Specific Dependencies

Target modules have their own dependencies declared in `targets/*/cpanfile`:

- **URL targets**: `URI`, `WWW::Mechanize`, `Mojo::URL`, `Mojo::UserAgent`
- **JSON targets**: `JSON`, `JSON::Parse`, `JSON::ON`, `Mojo::JSON`
- **Email targets**: `Email::Valid`, `Email::Address`

---

## Data Structures

### Test Case Structure

```perl
{
    seeds         => ['seeds/file1.txt', 'seeds/file2.txt'],
    targets       => ['Module1', 'Module2', 'Module3'],
    target_folder => 'targets/category'
}
```

### Module Result Structure

```perl
{
    module  => 'ModuleName',
    result  => 'output_string',
    defined => 1
}
```

### Queue Structure

- Type: `Thread::Queue`
- Contents: Seed strings (one per line from seed files)
- Access: Thread-safe dequeue operations

---

## Error Handling

### Error Types

1. **File Errors**: Missing seed files or target modules
   - Handled via `croak` from `Carp`
   - Stops execution immediately

2. **Module Errors**: Target module failures
   - Handled within target modules using `Try::Tiny`
   - Common pattern is returning `0` or `undef` to signal error
   - Execution continues with next seed

3. **Thread Errors**: Thread creation or execution failures
   - Perl's thread system handles most errors
   - Main thread waits for all workers

### Error Reporting

- File errors: Printed to STDERR via `croak`
- Module errors: Return values are compared like any other result and may trigger divergence
- Thread errors: Propagated to main thread

---

## Performance Considerations

### Optimization Strategies

1. **Thread Count**: Default 4 threads balances CPU usage and overhead
   - Adjust based on CPU cores: `--threads <count>`
   - Thread count is capped by `FUZZPM_MAX_THREADS` (default: 64)
   - Too many threads: Increased overhead, context switching
   - Too few threads: Underutilized CPU

2. **Queue Size**: Seeds loaded into memory
   - Large seed files: Higher memory usage
   - Consider streaming for very large files (future enhancement)

3. **Module Loading**: Modules loaded once at startup
   - Overhead: Minimal (one-time cost)
   - Benefit: Reused across all seeds

### Bottlenecks

1. **I/O**: Reading seed files (sequential, happens once)
2. **Module Execution**: Depends on target module performance
3. **Output Locking**: Synchronized printing can create contention with many threads

---

## Extension Points

### Adding New Components

1. **New CLI Options**: Extend `FuzzPM::Component::CLI`
2. **New Output Formats**: Modify `FuzzPM::Network::Runner::Result`
3. **New Mutation Strategies**: Extend `FuzzPM::Component::Mutator`
4. **New Target Types**: Create modules following the target interface

### Future Enhancements

- Streaming seed processing for large files
- Configurable output formats (JSON, CSV)
- Additional mutation strategies and deterministic replay support
- Parallel module execution within workers
- Result persistence and analysis tools

---

## Security Considerations

1. **Dynamic Module Loading**: Only loads modules from specified `target_folder`
   - Target modules are loaded with Perl `require` and executed as code
   - Treat YAML files and target folders as trusted inputs

2. **Thread Safety**: Target modules should be stateless or thread-safe
   - Shared state can cause race conditions
   - Each seed processed independently

3. **Input Validation**: Seeds are passed directly to target modules
   - Target modules responsible for input validation
   - Malicious seeds may cause module failures (expected behavior)

---

## Debugging

### Debug Output

Add debug statements in `FuzzPM::Network::Runner::Worker`:

```perl
print STDERR "DEBUG: Processing seed: $line\n";
print STDERR "DEBUG: Module results: " . Dumper(\@module_results) . "\n";
```

### Common Issues

1. **Module not found**: Check filename and package name match
2. **Thread errors**: Verify Perl has threading support
3. **No divergences**: Verify seeds are valid and modules process them
4. **Memory issues**: Reduce thread count or seed file size

---

## References

- [Perl Threads Documentation](https://perldoc.perl.org/threads)
- [Thread::Queue Documentation](https://metacpan.org/pod/Thread::Queue)
- [YAML::Tiny Documentation](https://metacpan.org/pod/YAML::Tiny)
