package Json_On {
    use strict;
    use warnings;
    use JSON::ON;
    use Try::Tiny;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        try {
            my $json    = JSON::ON->new();
            my $decoded = $json->decode($payload);

            return $decoded->get_ascii;
        }

        catch {
            return 0;
        }
    }
}

1;
