package MojoJson {
    use strict;
    use warnings;
    use Mojo::JSON ();
    use Try::Tiny;
    use JSON;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        try {
            my $data = Mojo::JSON::decode_json($payload);

            return JSON->new->canonical->encode($data);
        }

        catch {
            return 0;
        };

        return;
    }
}

1;
