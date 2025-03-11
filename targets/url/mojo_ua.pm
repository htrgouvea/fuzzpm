package Mojo_UA {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::UserAgent;

    sub new {
        my ($self, $payload) = @_;
        
        try {
            my $ua = Mojo::UserAgent->new();
            my $response = $ua->get($payload);
            
            return $response->req->url->host;
        }
        
        catch {
            return 0;
        }
    }
}

1;
