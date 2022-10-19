package Mechanize {
    use strict;
    use warnings;
    use Try::Tiny;
    use WWW::Mechanize;

    sub new {
        my ($self, $payload) = @_;

        try {
            my $mech = WWW::Mechanize -> new();
            $mech -> get ($payload);

            return $mech -> {uri};
        }

        catch {
            return undef;
        }
    }
}

1;