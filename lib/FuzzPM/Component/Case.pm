package FuzzPM::Component::Case {
    use strict;
    use warnings;
    use YAML::Tiny;
    use Carp qw(croak);
    use Getopt::Long;
    use English '-no_match_vars';

    our $VERSION = '0.0.3';

    sub new {
        my ($class, $case_file) = @_;

        GetOptions (
            'c|case=s' => \$case_file
        );

        if ($case_file) {
            my $yaml = YAML::Tiny -> read($case_file) or croak "Error reading file $case_file: $OS_ERROR";

            return $yaml -> [0] -> {test};
        }

        return 0;
    }
}

1;
