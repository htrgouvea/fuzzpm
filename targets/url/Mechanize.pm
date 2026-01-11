package Mechanize {
    use strict;
    use warnings;
    use Try::Tiny;
    use WWW::Mechanize;
    use HTTP::Request;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        my $result = try {
            my $request = HTTP::Request->new(GET => $payload);
            my $uri = $request->uri;

            return $uri->host if $uri && ref $uri;
            return $uri;
        }
        catch {
            0;
        };

        return $result;
    }
}

1;
