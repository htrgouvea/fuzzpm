package SimpleUri {
    use strict;
    use warnings;
    use URI;
    use Try::Tiny;

    our $VERSION = '0.0.1';

    sub new {
        my ($class, $payload) = @_;

        my $result = try {
            my $uri = URI -> new($payload);

            $uri -> host;
        }
        catch {
            0;
        };

        return $result;
    }
}

1;
