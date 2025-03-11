package FuzzPM::Runner {
    use strict;
    use warnings;
    use threads;
    use Thread::Queue;
    use threads::shared;
    use List::MoreUtils qw(any);

    my $OUTPUT_LOCK :shared = 1;

    sub run {
        my ($case_data, $num_threads) = @_;
        $num_threads //= 4;

        my $seed_files    = $case_data->{seeds};
        my $targets       = $case_data->{targets} || $case_data->{libs};
        my $target_folder = $case_data->{target_folder} // "targets";

        foreach my $target (@$targets) {
            my $module_path = "./" . $target_folder . "/" . lc($target) . ".pm";
            require $module_path;
        }

        my $q = Thread::Queue->new();
        foreach my $seed_file (@$seed_files) {
            open my $fh, '<', $seed_file or die "Cannot open file $seed_file: $!";
            while (my $line = <$fh>) {
                chomp $line;
                $q->enqueue($line);
            }
            close $fh;
        }
        $q->end();

        my @threads;
        for (1 .. $num_threads) {
            push @threads, threads->create(\&worker, $q, $targets);
        }
        $_->join() for @threads;
    }

    sub worker {
        my ($q, $targets) = @_;
        while (defined(my $line = $q->dequeue())) {
            {
                lock($OUTPUT_LOCK);
                print "[-] Seed \t -> $line\n";
            }

            my @results;
            foreach my $target (@$targets) {
                no strict 'refs';
                my $output = $target->new($line);
                use strict 'refs';
                push @results, { target => $target, output => $output }
                    if defined $output && $output;
            }

            if (@results > 1) {
                my $first = $results[0]->{output};
                my $divergence = 0;
                foreach my $res (@results) {
                    if ($res->{output} ne $first) {
                        $divergence = 1;
                        last;
                    }
                }
                if ($divergence) {
                    lock($OUTPUT_LOCK);
                    foreach my $res (@results) {
                        print "[+] $res->{target} \t $res->{output}\n";
                    }
                    print "\n";
                }
            }
        }
    }
}

1;