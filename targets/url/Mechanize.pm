package Mechanize {
    use strict;
    use warnings;
    use Try::Tiny;
    use WWW::Mechanize;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        try {
            my $mech = WWW::Mechanize->new();
            $mech->get($payload);
            my $uri = $mech->{uri};

            return $uri->host if $uri && ref $uri;
            return $uri;
        }
        catch {
            return 0;
        };

        return;
    }
}

1;