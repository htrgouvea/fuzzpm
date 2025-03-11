package FuzzPM::CLI {
    use strict;
    use warnings;
    use Getopt::Long;

    sub parse_options {
        my %opts;

        GetOptions(
            'c|case=s'   => \$opts{case},
            'm|mutate'   => \$opts{mutate},
            'h|help'     => \$opts{help},
            't|threads=i'=> \$opts{threads},
        );

        return \%opts;
    }
}

1;