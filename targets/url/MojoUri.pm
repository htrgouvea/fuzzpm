package MojoUri {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::URL;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        my $result = try {
            my $url = Mojo::URL->new($payload);

            $url->host;
        }
        catch {
            0;
        };

        return $result;
    }
}

1;
