package Email_Valid {
    use strict;
    use warnings;
    use Try::Tiny;
    use Email::Valid;

    our $VERSION = '0.0.1';

    sub new {
        my ($class, $payload) = @_;

        my $result = try {
            my $validated_address = Email::Valid -> address $payload;
            if ($validated_address) {
                return lc $validated_address;
            }
            return 0;
        }

        catch {
            0;
        };

        return $result;
    }
}

1;
