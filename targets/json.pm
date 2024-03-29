package Json {
    use strict;
    use warnings;
    use JSON;
    use Try::Tiny;
    use Data::Dumper;

    sub new {
        my ($self, $payload) = @_;

        try {
            my $json = JSON -> new();
            my $decoded = decode_json($payload);

            return Dumper($decoded);
        }

        catch {
            return 0;
        }
    }
}

1;