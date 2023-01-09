#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;

sub main {
    my $seed = $ARGV[0];
        
    if ($seed) {
        my @chars = split //, $seed;

        for (my $i = 0; $i < @chars; $i++) {
            my $random = int(rand(@chars));
            my $temp   = $chars[$i];

            $chars[$i]      = $chars[$random];
            $chars[$random] = $temp;
        }

        return join("", @chars);
    }

    return 0;
}

print main(), "\n";