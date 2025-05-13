#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use File::Temp qw(tempfile);
use FindBin;
use lib "$FindBin::Bin/../lib";
use FuzzPM::Case;

my ($fh, $filename) = tempfile(SUFFIX => '.yml');
print $fh <<"EOF";
test:
  seeds:
    - seeds/test.txt
  targets:
    - DummyModule
  target_folder: targets/dummy
EOF
close $fh;

my $case = FuzzPM::Case::load_case($filename);
is_deeply(
    $case,
    {
        seeds         => ['seeds/test.txt'],
        targets       => ['DummyModule'],
        target_folder => 'targets/dummy'
    },
    'Case loaded correctly'
);
