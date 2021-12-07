package Mojo_UA {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::UserAgent;

    sub new {
        my ($self, $payload) = @_;

        try {
            my $mojo_ua  = Mojo::UserAgent -> new();
            my $response = $mojo_ua -> get($payload);

            return  $response -> req() -> url() -> host();
        }

        catch {
            return undef;
        }
    }
}

1;