package FuzzPM::Component::CLI {
    use strict;
    use warnings;
    use Getopt::Long;

    sub new {
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