package MojoUa {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::UserAgent;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        my $result = try {
            my $ua = Mojo::UserAgent->new();
            my $tx = $ua->build_tx(GET => $payload);

            $tx->req->url->host;
        }
        catch {
            0;
        };

        return $result;
    }
}

1;
