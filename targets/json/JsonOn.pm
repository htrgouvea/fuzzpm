package JsonOn {
    use strict;
    use warnings;
    use JSON::ON;
    use Try::Tiny;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        my $result = try {
            my $json    = JSON::ON->new();
            my $decoded = $json->decode($payload);

            $decoded->get_ascii;
        }

        catch {
            0;
        };

        return $result;
    }
}

1;
