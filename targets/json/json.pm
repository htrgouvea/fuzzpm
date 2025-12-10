package Json {
    use strict;
    use warnings;
    use JSON;
    use Try::Tiny;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        try {
            my $json = JSON->new->canonical;
            my $data = $json->decode($payload);

            return $json->encode($data);
        }
        
        catch {
            return 0;
        };

        return;
    }
}

1;
