package Json_Parse {
    use strict;
    use warnings;
    use JSON::Parse qw(parse_json);
    use Try::Tiny;
    use Data::Dumper;

    sub new {
        my ($self, $payload) = @_;
        
        try {
            my $json_parse = JSON::Parse -> new();
            my $output     = $json_parse -> parse($payload);

            return $output;
        }

        catch {
            return undef;
        }
    }
}

1;


