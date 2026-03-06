package FuzzPM::Component::CLI {
    use strict;
    use warnings;
    use Getopt::Long;

    our $VERSION = '0.0.4';

    sub new {
        my ($class, %options) = @_;

        GetOptions (
            'c|case=s'    => \$options{case},
            'm|mutate'    => \$options{mutate},
            'mutate-times=i' => \$options{mutate_times},
            'h|help'      => \$options{help},
            't|threads=i' => \$options{threads},
            's|show-matches' => \$options{show_matches},
        );

        return \%options;
    }
}

1;
