package Json_On {
    use strict;
    use warnings;
    use JSON::ON;
    use Try::Tiny;
    use Data::Dumper;

    sub new {
        my ($self, $payload) = @_;

        try {
            my $json   = JSON::ON -> new();
            my $decode = $json -> decode($payload);

            return $decode;
        }

        catch {
            return undef;
        }
    }
}

1;