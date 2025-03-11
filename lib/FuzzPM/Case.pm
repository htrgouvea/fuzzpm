package FuzzPM::Case {
    use strict;
    use warnings;
    use YAML::Tiny;

    sub load_case {
        my ($file) = @_;
        my $yaml = YAML::Tiny -> read($file) or die "Error reading file $file: $!";

        return $yaml -> [0] -> {test};
    }
}

1;