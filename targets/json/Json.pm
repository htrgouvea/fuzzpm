package Json {
    use strict;
    use warnings;
    use JSON;
    use Try::Tiny;

    our $VERSION = '0.0.1';

    sub new {
        my ($class, $payload) = @_;

        my $result = try {
            my $json_codec = JSON -> new() -> canonical;
            my $decoded_data = $json_codec -> decode($payload);

            $json_codec -> encode($decoded_data);
        }

        catch {
            0;
        };

        return $result;
    }
}

1;
