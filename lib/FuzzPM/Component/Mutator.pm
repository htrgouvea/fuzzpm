package FuzzPM::Compontent::Mutator {
    use strict;
    use warnings;

    sub new {
        my ($class, $seed) = @_;

        if ($seed) {
            my @chars = split //, $seed;

            for (my $i = 0; $i < @chars; $i++) {
                my $random = int(rand(@chars));
                my $temp   = $chars[$i];

                $chars[$i]      = $chars[$random];
                $chars[$random] = $temp;
            }

            return join("", @chars);
        }

        return 0;
    }
}

1;
