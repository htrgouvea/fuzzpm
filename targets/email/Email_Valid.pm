package Email_Valid {
    use strict;
    use warnings;
    use Try::Tiny;
    use Email::Valid;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        my $result = try {
            my $address = Email::Valid->address($payload);

            $address ? lc($address) : 0;
        }

        catch {
            0;
        };

        return $result;
    }
}

1;
