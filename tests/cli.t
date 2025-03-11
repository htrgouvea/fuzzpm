#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;
use FindBin;
use lib "$FindBin::Bin/../lib";
use FuzzPM::CLI;

local @ARGV = qw(--case test.yml --threads 2);
my $opts = FuzzPM::CLI::parse_options();

is($opts->{case}, 'test.yml', 'Parsed case file option');
is($opts->{threads}, 2, 'Parsed threads option');
ok(!$opts->{help}, 'Help option is not set');
