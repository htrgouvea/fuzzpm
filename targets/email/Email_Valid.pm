package Email_Valid {
    use strict;
    use warnings;
    use Try::Tiny;
    use Email::Valid;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        try {
            my $address = Email::Valid->address($payload);

            return $address ? lc($address) : 0;
        }
        
        catch {
            return 0;
        };

        return;
    }
}

1;