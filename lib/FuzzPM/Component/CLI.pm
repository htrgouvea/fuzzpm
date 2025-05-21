package FuzzPM::Component::CLI {
    our $VERSION = '0.0.1';

    use strict;
    use warnings;
    use Getopt::Long;

    sub new {
        my ($self, %opts) = @_;

        GetOptions (
            'c|case=s'    => \$opts{case},
            'm|mutate'    => \$opts{mutate},
            'h|help'      => \$opts{help},
            't|threads=i' => \$opts{threads},
        );

        return \%opts;
    }
}

1;