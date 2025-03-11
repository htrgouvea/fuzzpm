#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use FuzzPM::CLI;
use FuzzPM::Case;
use FuzzPM::Runner;

my $opts = FuzzPM::CLI::parse_options();

if ( $opts->{help} || !$opts->{case} ) {
    print "Usage: $0 --case <file.yml> [--threads <num>]\n";
    exit 0;
}

my $case_data = FuzzPM::Case::load_case( $opts->{case} );

FuzzPM::Runner::run( $case_data, $opts->{threads} );