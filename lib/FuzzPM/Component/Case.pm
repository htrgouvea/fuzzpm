package FuzzPM::Component::Case {
    use strict;
    use warnings;
    use YAML::Tiny;

    sub new {
        my ($file) = @_;
        my $yaml = YAML::Tiny -> read($file) or die "Error reading file $file: $!";

        return $yaml -> [0] -> {test};
    }
}

1;