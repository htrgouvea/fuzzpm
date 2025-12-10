package SimpleUri {
    use strict;
    use warnings;
    use URI;
    use Try::Tiny;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        try {
            my $uri = URI->new($payload);

            return $uri->host;
        }
        catch {
            return 0;
        };

        return;
    }
}

1;
