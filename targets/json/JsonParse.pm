package JsonParse {
    use strict;
    use warnings;
    use JSON::Parse qw(parse_json);
    use Try::Tiny;
    use JSON;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        try {
            my $data = parse_json($payload);

            return JSON->new->canonical->encode($data);
        }
        catch {
            return 0;
        };

        return;
    }
}

1;
