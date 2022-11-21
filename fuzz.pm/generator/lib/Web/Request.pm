package Web::Request {

    use strict;
    use warnings;
    use URI::URL;
    use Web::Request::Parameter;
    
    sub new {
        my ($self, $url, $method) = @_;
        $url = substr($url, 0, index($url, '?')) if $url =~ /\?/;
        bless { url => $url, method => $method }, $self;
    }
    
    sub add_parameter {
        my ($self, $name, $type, $value, $source) = @_;
        my $p = Web::Request::Parameter->new($name, $type, $value, $source);
        push @{$self->{params}}, $p;
    }
    
    sub generate_requests {
        my ($self) = @_;

        my $params  = $self->{params};
        my $method  = $self->{method};
        my $current = 0;
        my @request = ($method);
        
        return sub {
        
            return undef unless $params;

            my $url = $self->{url};
            my @get;
            my @cookies;
            my %headers;
            my $pr = $params->[$current];

            for my $p (@$params)
            {
                if ($p->type eq P_HEADER)
                {
                    $headers{$p->name} = $p->value;
                }
                elsif ($p->type eq P_COOKIE)
                {
                    push @cookies, $p->name() . "=" . $p->value();
                }
                else
                {
                    push @get, $p->name() . "=" . $p->value();
                }
                $p->next_val() if $p == $pr;
            }
            
            my $content = join '&', @get;
            unless (grep(/$method/i, 'post', 'put', 'patch'))
            {
                $url .= "?" . $content;
                $content = "";
            }

            $headers{Cookie} = join ';', @cookies if @cookies;
            $current ++ if $pr->ended();
            $params = undef if $current >= @{$params};
            
            return (
                $method,
                $url,
                {
                    headers => { %headers },
                    content => $content,
                },
            );
        }
    }
    
}

1;
