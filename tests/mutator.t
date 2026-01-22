#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use FuzzPM::Component::Mutator;

our $VERSION = '0.0.1';

my $original_seed = 'hello';
my $mutated_seed = FuzzPM::Component::Mutator -> new($original_seed);

ok(defined $mutated_seed, 'Mutator returns a defined value');
is(length($mutated_seed), length($original_seed), 'Mutated string has same length as original');
isnt($mutated_seed, $original_seed, 'Mutated string is different from original');
ok($mutated_seed =~ /^[hello]+$/msx, 'Mutated string contains only characters from original');

done_testing();
