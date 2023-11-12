package Mojo_Json {
    use strict;
    use warnings;
    use Mojo::JSON qw(decode_json encode_json);
    use Try::Tiny;
    use Data::Dumper;

    sub new {
        my ($self, $payload) = @_;

       try {
            my $data = decode_json ($payload);

            return Dumper($data);
        }

        catch {
            return 0;
        }
    }
}

1;