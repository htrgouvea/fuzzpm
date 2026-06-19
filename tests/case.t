#!/usr/bin/env perl

use strict;
use English qw(-no_match_vars);
use Carp;
use warnings;
use Test::More tests => 2;
use FindBin;
use lib "$FindBin::Bin/../lib";
use FuzzPM::Component::Case;

our $VERSION = '0.0.1';

{
    my $fixture = "$FindBin::Bin/fixtures/test_case.yml";

    local @ARGV = ('--case', $fixture);
    my $case_data = FuzzPM::Component::Case->new();

    is_deeply(
        $case_data,
        {
            seeds         => ['seeds/test.txt'],
            targets       => ['DummyModule'],
            target_folder => 'targets/dummy'
        },
        'Case loaded correctly from YAML file'
    );
}

{
    local @ARGV = ();
    my $case_data = FuzzPM::Component::Case->new();

    is($case_data, 0, 'Returns 0 when no case file is provided');
}
