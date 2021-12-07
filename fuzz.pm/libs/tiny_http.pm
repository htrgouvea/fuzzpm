package Tiny_HTTP {
    use strict;
    use warnings;
    use Try::Tiny;
    use HTTP::Tiny;

    sub new {
        my ($self, $payload) = @_;

        try {
            my $tiny = HTTP::Tiny -> new() -> get ($payload);
            
            return $tiny -> {url};
        }

        catch {
            return undef;
        }
    }
}

1;