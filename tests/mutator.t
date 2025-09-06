#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use FuzzPM::Component::Mutator;

my $original = "hello";
my $mutated = FuzzPM::Component::Mutator->new($original);

ok(defined $mutated, 'Mutator returns a defined value');
is(length($mutated), length($original), 'Mutated string has same length as original');
isnt($mutated, $original, 'Mutated string is different from original');
ok($mutated =~ /^[hello]+$/, 'Mutated string contains only characters from original');

my $empty_mutated = FuzzPM::Component::Mutator->new("");
is($empty_mutated, 0, 'Empty string returns 0');

my $single_char = FuzzPM::Component::Mutator->new("a");
is($single_char, "a", 'Single character string remains unchanged');

my $repeated = "aaa";
my $repeated_mutated = FuzzPM::Component::Mutator->new($repeated);
is($repeated_mutated, $repeated, 'String with repeated characters remains unchanged');

my $complex = "Hello World!";
my $complex_mutated = FuzzPM::Component::Mutator->new($complex);
ok(defined $complex_mutated, 'Complex string mutation returns defined value');
is(length($complex_mutated), length($complex), 'Complex mutated string has same length');

my %original_chars;
my %mutated_chars;
map { $original_chars{$_}++ } split //, $complex;
map { $mutated_chars{$_}++ } split //, $complex_mutated;

is_deeply(\%mutated_chars, \%original_chars, 'Character frequency is preserved in mutation');

my $test_string = "abcdef";
my $mutation1 = FuzzPM::Component::Mutator->new($test_string);
my $mutation2 = FuzzPM::Component::Mutator->new($test_string);

if (length($test_string) > 1) {
    ok($mutation1 ne $mutation2 || $mutation1 ne $test_string, 
       'Multiple mutations produce different results');
}

my $undefined_result = FuzzPM::Component::Mutator->new(undef);
is($undefined_result, 0, 'Undefined input returns 0');

done_testing(); 