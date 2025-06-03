package FuzzPM::Component::Case {
    use strict;
    use warnings;
    use YAML::Tiny;
    use Carp qw(croak);
    use Getopt::Long;

    our $VERSION = '0.0.2';

    sub new {
        my ($self, $file) = @_;

        GetOptions (
            'c|case=s' => \$file
        );

        if ($file) {
             my $yaml = YAML::Tiny -> read($file) or croak "Error reading file $file: $!";

            return $yaml -> [0] -> {test};
        }

        return 0;
    }
}

1;