#!/usr/bin/env perl

use strict;
use warnings;
use Readonly;
Readonly my $TEST_COUNT => 3;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use FuzzPM::Component::CLI;

our $VERSION = '0.0.1';
plan tests => $TEST_COUNT;

local @ARGV = qw(--case test.yml --threads 2);
my $cli_options = FuzzPM::Component::CLI -> new();

is($cli_options -> {case}, 'test.yml', 'Parsed case file option');
is($cli_options -> {threads}, 2, 'Parsed threads option');
ok(!$cli_options -> {help}, 'Help option is not set');
