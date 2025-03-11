package Json_Parse {
    use strict;
    use warnings;
    use JSON::Parse qw(parse_json);
    use Try::Tiny;
    use JSON;

    sub new {
        my ($self, $payload) = @_;
        
        try {
            my $data = parse_json($payload);
            
            return JSON->new->canonical->encode($data);
        }
        
        catch {
            return 0;
        }
    }
}

1;
