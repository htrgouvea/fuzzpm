package FuzzPM::Network::Runner {
    use strict;
    use warnings;
    use threads;
    use Thread::Queue;
    use threads::shared;
    use List::MoreUtils qw(any);
    use Readonly;
    use Carp qw(croak);
    use English '-no_match_vars';

    our $VERSION = '0.0.1';

    Readonly my $DEFAULT_NUM_THREADS => 4;
    Readonly my $MAX_MUTATION_ATTEMPTS => 5;
    Readonly my $DIVERGED_TAG => q{+};
    Readonly my $MATCH_TAG => q{=};

    my $OUTPUT_LOCK : shared = 1;

    sub run {
        my ($test_case, $thread_count, $mutation_enabled, $show_matches, $mutation_count) = @_;

        $thread_count //= $DEFAULT_NUM_THREADS;
        if (defined $mutation_count && $mutation_count > 0) {
            $mutation_enabled = 1;
        }
        $mutation_enabled //= 0;
        if ($mutation_enabled) {
            if (!defined $mutation_count) {
                $mutation_count = 1;
            }
        }
        if (!$mutation_enabled) {
            $mutation_count = 0;
        }
        $show_matches //= 0;

        my $seed_files = $test_case -> {seeds};
        my $target_modules = $test_case -> {targets} || $test_case -> {libs};
        my $module_folder = $test_case -> {target_folder} // 'targets';

        foreach my $module ( @{ $target_modules } ) {
            my $module_path = "./$module_folder/" . $module . '.pm';

            require $module_path;
        }

        my $seed_queue = Thread::Queue -> new();

        foreach my $seed_file ( @{ $seed_files } ) {
            open my $seed_handle, '<', $seed_file or croak "Cannot open file $seed_file: $OS_ERROR";

            while (my $line = <$seed_handle>) {
                chomp $line;
                $seed_queue -> enqueue($line);
            }

            close $seed_handle or croak "Cannot close file $seed_file: $OS_ERROR";
        }

        $seed_queue -> end();

        my @threads;

        for (1 .. $thread_count) {
            push @threads, threads -> create(
                \&worker,
                $seed_queue,
                $target_modules,
                $mutation_enabled,
                $show_matches,
                $mutation_count
            );
        }

        foreach my $thread (@threads) {
            $thread -> join();
        }

        return 1;
    }

    sub worker {
        my ($seed_queue, $target_modules, $mutation_enabled, $show_matches, $mutation_count) = @_;

        while (defined(my $seed_line = $seed_queue -> dequeue())) {
            my $original_seed = $seed_line;
            my @payloads = ($original_seed);

            if ($mutation_enabled) {
                require FuzzPM::Component::Mutator;
                for my $mutation_index (1 .. $mutation_count) {
                    my $mutated = _mutate_seed($original_seed);
                    push @payloads, $mutated;
                }
            }

            for my $payload_index (0 .. $#payloads) {
                my $payload = $payloads[$payload_index];

                {
                    lock($OUTPUT_LOCK);
                    if ($payload_index == 0) {
                        print "[-] Seed\t-> $payload\n";
                    }
                    if ($payload_index != 0) {
                        print "[!] Mutated\t($payload_index/$mutation_count): $payload\n";
                    }
                }

                my @module_results;

                foreach my $module ( @{ $target_modules } ) {
                    my $result = $module -> new($payload);

                    push @module_results, {
                        module => $module,
                        result => $result,
                        defined => defined $result,
                    };
                }

                if (@module_results > 1) {
                    my $diverged = _results_diverged(\@module_results);
                    if ($diverged) {
                        lock($OUTPUT_LOCK);
                        _print_module_results($DIVERGED_TAG, \@module_results);
                    } elsif ($show_matches) {
                        lock($OUTPUT_LOCK);
                        _print_module_results($MATCH_TAG, \@module_results);
                    }
                } elsif ($show_matches) {
                    lock($OUTPUT_LOCK);
                    _print_module_results($MATCH_TAG, \@module_results);
                }
            }
        }
        return;
    }

    sub _mutate_seed {
        my ($seed) = @_;

        for (1 .. $MAX_MUTATION_ATTEMPTS) {
            my $mutated = FuzzPM::Component::Mutator -> new($seed);
            if ($mutated && $mutated ne '0' && $mutated ne $seed) {
                return $mutated;
            }
        }

        return $seed;
    }

    sub _results_diverged {
        my ($module_results) = @_;
        my $first_result = $module_results -> [0];

        foreach my $module_result (@{ $module_results }) {
            if ($module_result -> {defined} != $first_result -> {defined}) {
                return 1;
            }
            if ($module_result -> {defined} && $module_result -> {result} ne $first_result -> {result}) {
                return 1;
            }
        }

        return 0;
    }

    sub _print_module_results {
        my ($tag, $module_results) = @_;

        foreach my $module_result (@{ $module_results }) {
            my $display = $module_result -> {defined} ? $module_result -> {result} : '<undef>';
            print "[$tag] " . $module_result -> {module} . "\t" . $display . "\n";
        }

        print "\n";
        return;
    }

    return 1;
}

1;
