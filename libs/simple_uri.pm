package Simple_URI {
    use strict;
    use warnings;
    use URI;
    use Try::Tiny;

    sub new {
        my ($self, $payload) = @_;

        try {
            my $uri = URI -> new($payload);
            
            return $uri -> host();
        }

        catch {
            return undef;
        }
    }
}

1;