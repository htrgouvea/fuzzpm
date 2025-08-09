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

    my $OUTPUT_LOCK : shared = 1;

    sub run {
        my ($test_case, $num_threads) = @_;

        $num_threads //= $DEFAULT_NUM_THREADS;

        my $seed_files     = $test_case -> {seeds};
        my $target_modules = $test_case -> {targets} || $test_case -> {libs};
        my $module_folder  = $test_case -> {target_folder} // 'targets';

        foreach my $module ( @{ $target_modules } ) {
            my $module_path = "./$module_folder/" . lc($module) . '.pm';

            require $module_path;
        }

        my $queue = Thread::Queue -> new();

        foreach my $seed_file ( @{ $seed_files } ) {
            open my $fh, '<', $seed_file or croak "Cannot open file $seed_file: $OS_ERROR";

            while (my $line = <$fh>) {
                chomp $line;
                $queue -> enqueue($line);
            }

            close $fh or croak "Cannot close file $seed_file: $OS_ERROR";
        }

        $queue -> end();

        my @threads;

        for (1 .. $num_threads) {
            push @threads, threads -> create(\&worker, $queue, $target_modules);
        }

        foreach my $thr (@threads) {
            $thr -> join();
        }

        return 1;
    }

    sub worker {
        my ($queue, $target_modules) = @_;

        while (defined(my $line = $queue -> dequeue())) {
            {
                lock($OUTPUT_LOCK);
                print "[-] Seed\t-> $line\n";
            }

            my @module_results;

            foreach my $module ( @{ $target_modules } ) {
                no strict 'refs';

                my $result = $module -> new($line);

                use strict 'refs';

                if (defined $result && $result) {
                    push @module_results, { module => $module, result => $result };
                }
            }

            if (@module_results > 1) {
                my $first_output = $module_results[0] -> {result};
                my $diverged     = 0;

                foreach my $res (@module_results) {
                    if ($res -> {result} ne $first_output) {
                        $diverged = 1;
                        last;
                    }
                }

                if ($diverged) {
                    lock($OUTPUT_LOCK);

                    foreach my $res (@module_results) {
                        print '[+] ' . $res -> {module} . "\t" . $res -> {result} . "\n";
                    }

                    print "\n";
                }
            }
        }
        return;
    }

    return 1;
}

1;