#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 3;
use FindBin;
use lib "$FindBin::Bin/../lib";
use FuzzPM::Component::CLI;

our $VERSION = '0.0.1';

local @ARGV = qw(--case test.yml --threads 2);
my $opts = FuzzPM::Component::CLI -> new();

is($opts->{case}, 'test.yml', 'Parsed case file option');
is($opts->{threads}, 2, 'Parsed threads option');
ok(!$opts->{help}, 'Help option is not set');