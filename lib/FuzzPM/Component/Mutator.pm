package FuzzPM::Component::Mutator {
    our $VERSION = '0.0.1';

    use strict;
    use warnings;
    use Getopt::Long;

    sub new {
        my ($self, $seed) = @_;

        GetOptions (
            's|seed=s' => \$seed
        );

        if ($seed) {
            my @chars = split //, $seed;

            foreach my $i (0 .. $#chars) {
                my $random = int(rand(@chars));
                my $temp   = $chars[$i];

                $chars[$i]      = $chars[$random];
                $chars[$random] = $temp;
            }

            return join('', @chars);
        }

        return 0;
    }
}

1;
