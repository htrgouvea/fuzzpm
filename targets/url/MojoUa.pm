package MojoUa {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::UserAgent;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        try {
            my $ua = Mojo::UserAgent->new();
            my $response = $ua->get($payload);

            return $response->req->url->host;
        }
        catch {
            return 0;
        };

        return;
    }
}

1;
