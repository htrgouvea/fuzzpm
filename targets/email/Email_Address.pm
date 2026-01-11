package Email_Address {
    use strict;
    use warnings;
    use Try::Tiny;
    use Email::Address;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $payload) = @_;

        my $result = try {
            my @addresses = Email::Address->parse($payload);

            @addresses ? lc($addresses[0]->address) : 0;
        }

        catch {
            0;
        };

        return $result;
    }
}

1;
