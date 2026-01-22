package JsonParse {
    use strict;
    use warnings;
    use JSON::Parse qw(parse_json);
    use Try::Tiny;
    use JSON;

    our $VERSION = '0.0.1';

    sub new {
        my ($class, $payload) = @_;

        my $result = try {
            my $decoded_data = parse_json($payload);

            JSON -> new() -> canonical -> encode($decoded_data);
        }

        catch {
            0;
        };

        return $result;
    }
}

1;
