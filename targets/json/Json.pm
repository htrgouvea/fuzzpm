package Json {
    use strict;
    use warnings;
    use JSON;
    use Try::Tiny;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        my $result = try {
            my $json = JSON->new->canonical;
            my $data = $json->decode($payload);

            $json->encode($data);
        }

        catch {
            0;
        };

        return $result;
    }
}

1;
