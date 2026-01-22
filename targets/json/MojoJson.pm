package MojoJson {
    use strict;
    use warnings;
    use Mojo::JSON ();
    use Try::Tiny;
    use JSON;

    our $VERSION = '0.0.1';

    sub new {
        my ($class, $payload) = @_;

        my $result = try {
            my $decoded_data = Mojo::JSON::decode_json($payload);

            JSON -> new() -> canonical -> encode($decoded_data);
        }

        catch {
            0;
        };

        return $result;
    }
}

1;
