#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use URI;
use Try::Tiny;
use HTTP::Tiny;
use Mojolicious::Lite -signatures;

get "/" => sub ($request) {
    my $endpoint = $request -> param("endpoint");

    if ($endpoint) { 
        my $uri = URI -> new($endpoint);

        if ($uri -> host() ne "google.com") {
            try {
                my $getContent = HTTP::Tiny -> new() -> get($endpoint);

                if ($getContent -> {success}) {
                    
                    return ($request -> render (
                        text => "ok"
                    )); 
                }
            }

            catch {
                return ($request -> render (
                    text => "error"
                ));
            }
        }
    }
};

app -> start(); # perl app.pl daemon -m production -l http://\*:8080