package FuzzPM::Component::Case {
    use strict;
    use warnings;
    use YAML::Tiny;
    use Carp qw(croak);

    sub new {
        my ($file) = @_;
        my $yaml = YAML::Tiny -> read($file) or croak "Error reading file $file: $!";

        return $yaml -> [0] -> {test};
    }
}

1;