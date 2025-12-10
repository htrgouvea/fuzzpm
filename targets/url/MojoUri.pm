package MojoUri {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::URL;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        try {
            my $url = Mojo::URL->new($payload);

            return $url->host;
        }
        catch {
            return 0;
        };

        return;
    }
}

1;
