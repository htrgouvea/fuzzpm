#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use FuzzPM::Component::Mutator;

our $VERSION = '0.0.1';
plan tests => 5;

{
    my $original_seed = 'hello world';
    my $mutated_seed  = FuzzPM::Component::Mutator->new($original_seed);

    ok(defined $mutated_seed, 'Mutator returns a defined value for a normal seed');
    ok(length($mutated_seed) >= 1, 'Mutated string has at least one byte');
}

{
    my $result = FuzzPM::Component::Mutator->new(q{});

    is($result, 0, 'Returns 0 for an empty seed');
}

{
    my $result = FuzzPM::Component::Mutator->new(undef);

    is($result, 0, 'Returns 0 for an undefined seed');
}

{
    my $single_char   = 'A';
    my $mutated       = FuzzPM::Component::Mutator->new($single_char);

    ok(defined $mutated, 'Mutator handles single-character seeds without crashing');
}
