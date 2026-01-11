package MojoJson {
    use strict;
    use warnings;
    use Mojo::JSON ();
    use Try::Tiny;
    use JSON;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        my $result = try {
            my $data = Mojo::JSON::decode_json($payload);

            JSON->new->canonical->encode($data);
        }

        catch {
            0;
        };

        return $result;
    }
}

1;
