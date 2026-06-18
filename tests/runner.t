#!/usr/bin/env perl

use strict;
use warnings;
use Carp qw(croak);
use English '-no_match_vars';
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

    ok(!FuzzPM::Network::Runner::_results_diverged($results), ## no critic (Subroutines::ProtectPrivateSubs)
        'No divergence when all modules return the same result');
}

# _results_diverged: different string results -> divergence
{
    my $results = [
        { module => 'ModA', result => 'foo', defined => 1 },
        { module => 'ModB', result => 'bar', defined => 1 },
    ];

    ok(FuzzPM::Network::Runner::_results_diverged($results), ## no critic (Subroutines::ProtectPrivateSubs)
        'Divergence detected when modules return different results');
}

# _results_diverged: one defined, one undef -> divergence
{
    my $results = [
        { module => 'ModA', result => 'foo', defined => 1 },
        { module => 'ModB', result => undef, defined => 0 },
    ];

    ok(FuzzPM::Network::Runner::_results_diverged($results), ## no critic (Subroutines::ProtectPrivateSubs)
        'Divergence detected when one module returns undef and another does not');
}

# _results_diverged: single module -> never diverges
{
    my $results = [
        { module => 'ModA', result => 'only', defined => 1 },
    ];

    ok(!FuzzPM::Network::Runner::_results_diverged($results), ## no critic (Subroutines::ProtectPrivateSubs)
        'Single module result is never diverged');
}

# _results_diverged: both undef -> no divergence
{
    my $results = [
        { module => 'ModA', result => undef, defined => 0 },
        { module => 'ModB', result => undef, defined => 0 },
    ];

    ok(!FuzzPM::Network::Runner::_results_diverged($results), ## no critic (Subroutines::ProtectPrivateSubs)
        'No divergence when all modules return undef');
}

# _print_module_results: output contains expected tag and module name
{
    my $results = [
        { module => 'ModA', result => 'hello', defined => 1 },
        { module => 'ModB', result => undef,   defined => 0 },
    ];

    my $output = q{};
    open my $fh, '>', \$output or croak "Cannot open string ref: $OS_ERROR";
    {
        local *STDOUT = $fh;
        FuzzPM::Network::Runner::_print_module_results(q{+}, $results); ## no critic (Subroutines::ProtectPrivateSubs)
    }
    close $fh or croak "Cannot close string ref: $OS_ERROR";

    like($output, qr/[[][+][]][ ]ModA\thello/msx, 'Prints defined result with tag and module name');
}
