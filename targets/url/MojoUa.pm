package MojoUa {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::UserAgent;

    our $VERSION = '0.0.1';

    sub new {
        my ($class, $payload) = @_;

        my $result = try {
            my $user_agent = Mojo::UserAgent -> new();
            my $transaction = $user_agent -> build_tx(GET => $payload);

            $transaction -> req -> url -> host;
        }
        catch {
            0;
        };

        return $result;
    }
}

1;
