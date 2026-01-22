#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use FuzzPM::Component::CLI;
use FuzzPM::Component::Case;
use FuzzPM::Network::Runner;
use English qw(-no_match_vars);

our $VERSION = '0.0.4';

my $cli_options = FuzzPM::Component::CLI -> new();

if ($cli_options -> {help} || !$cli_options -> {case}) {
    print <<"END_HELP";

        FuzzPM v$VERSION
        Core Commands
        ==============
        	Command        Description
        	--------       -------------
        	--case         Define the use case of targets
        	--threads      Set the number of concurrent threads
        	--mutate       Enable seed mutation (shuffles characters)
        	--mutate-times Set how many mutations to run per seed
        	--show-matches Print target output even when they agree

END_HELP

    exit 0;
}

my $case_data = FuzzPM::Component::Case -> new($cli_options -> {case});

FuzzPM::Network::Runner::run(
    $case_data,
    $cli_options -> {threads},
    $cli_options -> {mutate},
    $cli_options -> {show_matches},
    $cli_options -> {mutate_times},
);
