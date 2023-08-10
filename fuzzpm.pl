#!/usr/bin/env perl

use 5.030;
use strict;
use warnings;
use YAML::Tiny;
use Getopt::Long;
use Find::Lib "./lib";
use List::MoreUtils qw(any);

sub main {
    my ($case, $help, @result);

    Getopt::Long::GetOptions (
        "c|case=s" => \$case,
        "h|help"   => \$help
    );

    if ($case) {
        my $yamlfile = YAML::Tiny -> read($case);

        foreach my $seed_dump ($yamlfile -> [0] -> {test} -> {seeds}) {
            for my $seed (@$seed_dump) {
                open (my $file, "<", $seed);

                while (<$file>) {
                    chomp ($_);
                    print "[-] Seed \t -> $_\n";
                    
                    foreach my $lib_dump ($yamlfile -> [0] -> {test} -> {targets}) {
                        for my $lib (@$lib_dump) {
                            require "./targets/" . lc $lib . ".pm";
                    
                            my $fuzz = $lib -> new($_);
                                
                            if ($fuzz) {
                                push @result, $fuzz;

                                if (any {$_ ne $fuzz} @result) {
                                    print "[+] $lib \t $fuzz\n";  
                                }                
                            }
                        }
                    }

                    print "\n";
                }
                
                close ($file);
            }
        }
    }

    else {
        print "[-] Usage: fuzzpm.pl -c <case>\n";
        return 0;
    }
}

exit main();