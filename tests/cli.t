#!/usr/bin/env perl

use strict;
use warnings;
use Readonly;
Readonly my $TEST_COUNT   => 7;
Readonly my $MUTATE_TIMES => 5;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use FuzzPM::Component::CLI;

our $VERSION = '0.0.1';
plan tests => $TEST_COUNT;

{
    local @ARGV = qw(--case test.yml --threads 2);
    my $cli_options = FuzzPM::Component::CLI->new();

    is($cli_options->{case},    'test.yml', 'Parsed case file option');
    is($cli_options->{threads}, 2,          'Parsed threads option');
    ok(!$cli_options->{help},               'Help option is not set by default');
}

{
    local @ARGV = ('--mutate', '--mutate-times', $MUTATE_TIMES);
    my $cli_options = FuzzPM::Component::CLI->new();

    ok($cli_options->{mutate},                          'Parsed mutate flag');
    is($cli_options->{mutate_times}, $MUTATE_TIMES,     'Parsed mutate-times option');
}

{
    local @ARGV = qw(--show-matches);
    my $cli_options = FuzzPM::Component::CLI->new();

    ok($cli_options->{show_matches}, 'Parsed show-matches flag');
}

{
    local @ARGV = qw(--help);
    my $cli_options = FuzzPM::Component::CLI->new();

    ok($cli_options->{help}, 'Parsed help flag');
}
