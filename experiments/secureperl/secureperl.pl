#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use Mojo::File;
use Data::Dumper;
use Path::Iterator::Rule;

sub main {
    my $rule = Path::Iterator::Rule -> new() -> file() -> not_empty();
    
    $rule -> skip_dirs(".git") -> file();
    $rule -> name("*.pl", "*.pm", "*.t");

    for my $file ($rule -> all(@ARGV)) {
        # print "\n $file \n";

        my $resources = Mojo::File -> new($file);
        my @source = $resources -> slurp();
        
        if (grep {$_ =~ m/"strict"/} @source) {
            print "Visitor $_ in the guest list\n";
        } 
    }
}

exit main();