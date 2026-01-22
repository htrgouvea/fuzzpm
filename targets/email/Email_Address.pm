package Email_Address {
    use strict;
    use warnings;
    use Try::Tiny;
    use Email::Address;

    our $VERSION = '0.0.1';

    sub new {
        my ($class, $payload) = @_;

        my $result = try {
            my @addresses = Email::Address -> parse($payload);
            if (@addresses) {
                return lc($addresses[0] -> address);
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
