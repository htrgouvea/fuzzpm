package JsonParse {
    use strict;
    use warnings;
    use JSON::Parse qw(parse_json);
    use Try::Tiny;
    use JSON;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        my $result = try {
            my $data = parse_json($payload);

            JSON->new->canonical->encode($data);
        }

        catch {
            0;
        };

        return $result;
    }
}

1;
