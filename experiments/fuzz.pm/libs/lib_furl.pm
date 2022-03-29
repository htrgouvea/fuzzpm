package Lib_Furl {
    use strict;
    use warnings;
    use Try::Tiny;
    use Furl;

    sub new {
        my ($self, $payload) = @_;

        try {
            my $furl = Furl -> new();
            my $resfurl = $furl -> get($payload);

            return  $resfurl -> {request_src} -> {url};
        }

        catch {
            return undef;
        }
    }
}

1;