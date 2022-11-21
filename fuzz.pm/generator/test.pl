use strict;
use warnings;
use lib './lib';
use threads;
use threads::shared;
use Data::Dumper;
use HTTP::Tiny;
use Thread::Queue;
use Threads::Manager;
use Web::Request::Generator;
use Web::Payload::Wordlist;
use Web::Payload::IntRange;

my $g = Web::Request::Generator->new("HEAD", "http://127.0.0.1:3000/");
$g->add_parameter("name", "value", P_URL, 1, Web::Payload::Wordlist->new('test.pl'));
$g->add_parameter("numb", "0", P_URL, 1, Web::Payload::IntRange->new(1, 10, 1));
$g->add_parameter("User-Agent", "unknown", P_HEADER, 0);
$g->add_parameter("test", "t", P_COOKIE, 0);
my $queue = Thread::Queue->new;

sub feed_queue {
    if ($g->next_request())
    {
        $queue->enqueue([$g->build_request()]);
    }
    else
    {
        $queue->end();
    }
}

sub request {
    my $http = HTTP::Tiny->new;
    while (defined(my $req = $queue->dequeue())) {
        my $resp = $http->request(@$req);
    }
}

my $m = Threads::Manager->new(\&request);

$m->run(5)->wait_all(\&feed_queue);
