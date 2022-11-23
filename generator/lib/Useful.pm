package Useful;

use strict;
use warnings;
use HTTP::Tiny;
use MIME::Base64;
use Time::HiRes qw(gettimeofday tv_interval);

sub get_headers
{
    my ($url, %options) = @_;
    my $http = HTTP::Tiny->new(%options);
    my $resp = $http->head($url);
    $resp->{success} ? $resp->{headers} : {}
}

sub request_average_time
{
    my ($method, $url, $count, %options) = @_;
    my $http = HTTP::Tiny->new(%options);
    $count = 5 unless $count;
    my @load_times;
    my $average = 0;
    for (my $i = 0; $i < $count; $i ++)
    {
        my $start = [gettimeofday];
        my $resp = $http->request($method, $url);
        push @load_times, tv_interval($start);
    }
    $average += $_ / $count for @load_times;
    wantarray ? @load_times : $average;
}

sub get_emails{
    my ($input_str) = @_;
    return sub {
        while ($input_str =~ m/([\w\d\._%\+\-]+@[\w\d\.\-]+(\.[\w\d]+)+)/ig)
        {
            return $1;
        }
        return undef;
    }
}

1;
