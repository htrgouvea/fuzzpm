package Mojo_Json {
    use strict;
    use warnings;
    use Mojo::JSON ();
    use Try::Tiny;
    use JSON;

    sub new {
        my ($self, $payload) = @_;
        
        try {
            my $data = Mojo::JSON::decode_json($payload);
            
            return JSON->new->canonical->encode($data);
        }
        
        catch {
            return 0;
        }
    }
}

1;
