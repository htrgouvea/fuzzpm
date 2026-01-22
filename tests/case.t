#!/usr/bin/env perl

use strict;
use English qw(-no_match_vars);
use Carp;
use warnings;
use Test::More tests => 1;
use File::Temp qw(tempfile);
use FindBin;
use lib "$FindBin::Bin/../lib";
use FuzzPM::Component::Case;

our $VERSION = '0.0.1';

my ($file_handle, $filename) = tempfile(SUFFIX => '.yml');

print {$file_handle} <<"EOF";
test:
  seeds:
    - seeds/test.txt
  targets:
    - DummyModule
  target_folder: targets/dummy
EOF
close $file_handle or croak 'Could not close filehandle: ' . $OS_ERROR;

local @ARGV = ('--case', $filename);

my $case_data = FuzzPM::Component::Case -> new();

is_deeply(
    $case_data,
    {
        seeds         => ['seeds/test.txt'],
        targets       => ['DummyModule'],
        target_folder => 'targets/dummy'
    },
    'Case loaded correctly'
);
