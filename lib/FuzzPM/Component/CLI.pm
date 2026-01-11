package FuzzPM::Component::CLI {
    use strict;
    use warnings;
    use Getopt::Long;

    our $VERSION = '0.0.4';

    sub new {
        my ($self, %opts) = @_;

        GetOptions (
            'c|case=s'    => \$opts{case},
            'm|mutate'    => \$opts{mutate},
            'h|help'      => \$opts{help},
            't|threads=i' => \$opts{threads},
            's|show-matches' => \$opts{show_matches},
        );

        return \%opts;
    }
}

1;
