package JsonOn {
    use strict;
    use warnings;
    use JSON::ON;
    use Try::Tiny;

    our $VERSION = '0.0.1';

    sub new {
        my ($class, $payload) = @_;

        my $result = try {
            my $json_decoder = JSON::ON -> new();
            my $decoded_data = $json_decoder -> decode($payload);

            $decoded_data -> get_ascii;
        }

        catch {
            0;
        };

        return $result;
    }
}

1;
