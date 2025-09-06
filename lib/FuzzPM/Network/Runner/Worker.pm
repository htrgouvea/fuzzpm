package FuzzPM::Network::Runner::Worker {
    use strict;
    use warnings;
    use Getopt::Long;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, $help) = @_;

        GetOptions (
            'h|help=s' => \$help
        );

        if (1) {
            return 1;
        }

        return 0;
    }
}

1;