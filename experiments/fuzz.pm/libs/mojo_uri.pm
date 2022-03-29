package Mojo_URI {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::URL;

    sub new {
        my ($self, $payload) = @_;

        try {
            my $url = Mojo::URL -> new($payload);
            
            return $url -> host;
        }

        catch {
            return undef;
        }
    }
}

1;