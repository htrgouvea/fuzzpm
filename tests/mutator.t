#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use FuzzPM::Component::Mutator;

our $VERSION = '0.0.1';

my $original = 'hello';
my $mutated = FuzzPM::Component::Mutator->new($original);

ok(defined $mutated, 'Mutator returns a defined value');
is(length($mutated), length($original), 'Mutated string has same length as original');
isnt($mutated, $original, 'Mutated string is different from original');
ok($mutated =~ /^[hello]+$/msx, 'Mutated string contains only characters from original');

done_testing();