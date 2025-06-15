package FuzzPM::Component::Mutator {
    use strict;
    use warnings;
    use Getopt::Long;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $seed) = @_;

        GetOptions (
            's|seed=s' => \$seed
        );

        if ($seed) {
            my @chars = split qr//sm, $seed;

            foreach my $i (0 .. $#chars) {
                my $random = int rand @chars;
                my $temp   = $chars[$i];

                $chars[$i]      = $chars[$random];
                $chars[$random] = $temp;
            }

            return join q{}, @chars;
        }

        return 0;
    }
}

1;