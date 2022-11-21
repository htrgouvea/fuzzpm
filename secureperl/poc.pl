#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Devel::Graph;

sub main {
    my $file    = $ARGV[0];
    my $grapher = Devel::Graph->new();
    my $graph   = $grapher -> graph($file);

    print $graph -> as_ascii();
}

main();