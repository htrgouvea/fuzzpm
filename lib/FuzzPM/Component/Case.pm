package FuzzPM::Component::Case {
    use strict;
    use warnings;
    use YAML::Tiny;
    use Carp qw(croak);
    use Getopt::Long;
    use English '-no_match_vars';

    our $VERSION = '0.0.3';

    sub new {
        my ($self, $file) = @_;

        GetOptions (
            'c|case=s' => \$file
        );

        if ($file) {
             my $yaml = YAML::Tiny -> read($file) or croak "Error reading file $file: $OS_ERROR";

            return $yaml -> [0] -> {test};
        }

        return 0;
    }
}

1;