package FuzzPM::Runner {
    use strict;
    use warnings;
    use threads;
    use Thread::Queue;
    use threads::shared;
    use List::MoreUtils qw(any);

    my $OUTPUT_LOCK : shared = 1;

    sub run {
        my ($test_case, $num_threads) = @_;
        
        $num_threads //= 4;

        my $seed_files     = $test_case -> {seeds};
        my $target_modules = $test_case -> {targets} || $test_case -> {libs};
        my $module_folder  = $test_case -> {target_folder} // "targets";

        foreach my $module (@$target_modules) {
            my $module_path = "./" . $module_folder . "/" . lc($module) . ".pm";
            
            require $module_path;
        }

        my $queue = Thread::Queue -> new();
        
        foreach my $seed_file (@$seed_files) {
            open my $fh, '<', $seed_file or die "Cannot open file $seed_file: $!";
            
            while (my $line = <$fh>) {
                chomp $line;
                $queue -> enqueue($line);
            }
            
            close $fh;
        }
        
        $queue -> end();

        my @threads;
        
        for (1 .. $num_threads) {
            push @threads, threads -> create(\&worker, $queue, $target_modules);
        }
        
        $_ -> join() for @threads;
    }

    sub worker {
        my ($queue, $target_modules) = @_;
        
        while (defined(my $line = $queue -> dequeue())) {
            {
                lock($OUTPUT_LOCK);
                print "[-] Seed\t-> $line\n";
            }

            my @module_results;
            
            foreach my $module (@$target_modules) {
                no strict 'refs';
                
                my $result = $module -> new($line);
                
                use strict 'refs';
                
                push @module_results, { module => $module, result => $result }
                    if defined $result && $result;
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
                        print "[+] " . $res -> {module} . "\t" . $res -> {result} . "\n";
                    }
                    
                    print "\n";
                }
            }
        }
    }
}

1;