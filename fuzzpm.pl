#!/usr/bin/env perl

our $VERSION = '0.0.2';

use strict;
use warnings;
use lib 'lib';
use FuzzPM::Component::CLI;
use FuzzPM::Component::Case;
use FuzzPM::Network::Runner;
use English qw(-no_match_vars);

my $opts = FuzzPM::Component::CLI -> new();

if ($opts -> {help} || !$opts -> {case}) {
    print 'Usage: ' . $PROGRAM_NAME . " --case <file.yml> [--threads <num>]\n";
    
    exit 0;
}

my $case_data = FuzzPM::Component::Case -> new ($opts -> {case});

FuzzPM::Network::Runner::run($case_data, $opts -> {threads});