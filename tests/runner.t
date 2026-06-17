#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use FuzzPM::Network::Runner;

our $VERSION = '0.0.1';
plan tests => 6;

# _results_diverged: all results agree -> no divergence
{
    my $results = [
        { module => 'ModA', result => 'foo', defined => 1 },
        { module => 'ModB', result => 'foo', defined => 1 },
    ];

    ok(!FuzzPM::Network::Runner::_results_diverged($results),
        'No divergence when all modules return the same result');
}

# _results_diverged: different string results -> divergence
{
    my $results = [
        { module => 'ModA', result => 'foo', defined => 1 },
        { module => 'ModB', result => 'bar', defined => 1 },
    ];

    ok(FuzzPM::Network::Runner::_results_diverged($results),
        'Divergence detected when modules return different results');
}

# _results_diverged: one defined, one undef -> divergence
{
    my $results = [
        { module => 'ModA', result => 'foo', defined => 1 },
        { module => 'ModB', result => undef, defined => 0 },
    ];

    ok(FuzzPM::Network::Runner::_results_diverged($results),
        'Divergence detected when one module returns undef and another does not');
}

# _results_diverged: single module -> never diverges
{
    my $results = [
        { module => 'ModA', result => 'only', defined => 1 },
    ];

    ok(!FuzzPM::Network::Runner::_results_diverged($results),
        'Single module result is never diverged');
}

# _results_diverged: both undef -> no divergence
{
    my $results = [
        { module => 'ModA', result => undef, defined => 0 },
        { module => 'ModB', result => undef, defined => 0 },
    ];

    ok(!FuzzPM::Network::Runner::_results_diverged($results),
        'No divergence when all modules return undef');
}

# _print_module_results: output contains expected tag and module name
{
    my $results = [
        { module => 'ModA', result => 'hello', defined => 1 },
        { module => 'ModB', result => undef,   defined => 0 },
    ];

    my $output = q{};
    open my $fh, '>', \$output or die "Cannot open string ref: $!";
    {
        local *STDOUT = $fh;
        FuzzPM::Network::Runner::_print_module_results('+', $results);
    }
    close $fh or die "Cannot close string ref: $!";

    like($output, qr/\[\+\]\ ModA\thello/sx, 'Prints defined result with tag and module name');
}
