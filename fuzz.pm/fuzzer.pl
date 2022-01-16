#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use YAML::Tiny;
use List::MoreUtils qw(any);

sub main {
    my $case = $ARGV[0];

    if ($case) {
        my $yamlfile = YAML::Tiny -> read($case);
        my @seeds    = $yamlfile -> [0] -> {test} -> {seeds};

        foreach my $seed_dump (@seeds) {
            for my $seed (@$seed_dump) {
                open (my $file, "<", $seed);

                while (<$file>) {
                    chomp ($_);
                    print "[-] Seed \t -> $_\n";

                    my @libs   = $yamlfile -> [0] -> {test} -> {libs};
                    my @result = ();
                    
                    foreach my $lib_dump (@libs) {
                        for my $lib (@$lib_dump) {
                            require "./libs/" . lc $lib . ".pm";
                    
                            my $fuzz = $lib -> new($_);
                                
                            if ($fuzz) {
                                push @result, $fuzz;

                                if (any {$_ ne $fuzz} @result) {
                                    print "[+] $lib \t $fuzz\n";  
                                }                
                            }
                        }
                    }

                    print "\n\n";
                }
                
                close ($file);
            }
        }
    }

    return 0;
}

exit main();