#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use FuzzPM::Component::CLI;
use FuzzPM::Component::Case;
use FuzzPM::Network::Runner;
use English qw(-no_match_vars);

our $VERSION = '0.0.4';

my $opts = FuzzPM::Component::CLI -> new();

if ($opts -> {help} || !$opts -> {case}) {
    print "
        \rFuzzPM v$VERSION
        \rCore Commands
        \r==============
        \r\tCommand        Description
        \r\t--------       -------------
        \r\t--case         Define the use case of targets
        \r\t--threads      Set the number of concurrent threads\n\n";
    

    exit 0;
}

my $case_data = FuzzPM::Component::Case -> new ($opts -> {case});

FuzzPM::Network::Runner::run($case_data, $opts -> {threads});