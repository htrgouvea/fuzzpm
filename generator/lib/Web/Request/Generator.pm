package Web::Request::Generator {
    use strict;
    use warnings;
    use URI::Escape;
    use overload "<>" => \&iterate;
    use parent 'Exporter';

    our @EXPORT = qw(P_URL P_BODY P_PATH P_COOKIE P_HEADER);

    use constant {
        P_URL       => 1,
        P_BODY      => 2,
        P_PATH      => 3,
        P_COOKIE    => 4,
        P_HEADER    => 5,
    };
    
    sub new {
        my ($self, $method, $url) = @_;
        #$url = substr($url, 0, index($url, "?")) if $url =~ /\?/;
        bless {
            url     => $url,
            method  => $method,
            params  => [],
            sources => [],
            current => 0,
        }, $self
    }


    sub build_request {
        my ($self) = @_;
        my $params  = $self->{params};
        my $sources = $self->{sources};
        my @url_params;
        my %headers;
        my @cookies;
        my @body_params;

        for (my $i = 0; $i < @{$params}; $i ++) {
            my $p = $params->[$i];
            my $s = $sources->[$i];
            my $v = ($i == $self->{current}) ? $s->get_payload() : $p->{value};
            if ($p->{type} == P_URL) {
                push @url_params, $p->{name} . "=" . uri_escape($v);
            } elsif ($p->{type} == P_BODY) {
                push @body_params, $p->{name} . "=" . uri_escape($v);
            } elsif ($p->{type} == P_COOKIE) {
                push @cookies, $p->{name} . "=" . uri_escape($v);
            }  elsif ($p->{type} == P_HEADER) {
                $headers{$p->{name}} = uri_escape($v);
            }
        }
        my $url = $self->{url} . "?" . join "&", @url_params;
        my $body = join "&", @body_params;
        $headers{Cookie} = join ";", @cookies if @cookies;
        return (
            $self->{method},
            $url,
            {
                headers => { %headers },
                content => $body,
            },
        )
    }

    sub next_request {
        my ($self) = @_;
        my $params = $self->{params};
        my $sources = $self->{sources};
        while ($self->{current} <= @$params) {
            my $p = $params->[$self->{current}];
            my $s = $sources->[$self->{current}];
            $self->{current} ++ && next unless $p->{attack} && $s;
            return 1 if $s && $s->next_payload();
            $self->{current} ++;
        }
        0;
    }

    sub add_parameter {
        my ($self, $name, $value, $type, $attack, $source) = @_;
        my $params  = $self->{params};
        my $sources = $self->{sources};

        my $param = {
           name     => $name,
           value    => $value,
           type     => $type,
           attack   => $attack,
       };

        push @{$params}, $param;
        push @{$sources}, $source;
    }
}

1;
