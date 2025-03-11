package Json {
    use strict;
    use warnings;
    use JSON;
    use Try::Tiny;

    sub new {
        my ($self, $payload) = @_;
        
        try {
            my $json = JSON->new->canonical;
            my $data = $json->decode($payload);
            
            return $json->encode($data);
        }
        
        catch {
            return 0;
        }
    }
}

1;
