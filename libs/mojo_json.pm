package Mojo_Json {
    use strict;
    use warnings;
    use Mojo::JSON qw(decode_json encode_json);
    use Try::Tiny;

    sub new {
        my ($self, $payload) = @_;
        
       try {
            my $data = decode_json ($payload);

            return $data;
        }

        catch {
            return undef;
        }
    }
}

1;