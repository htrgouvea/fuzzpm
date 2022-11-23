package Utils::TCPClient {
    use strict;
    use threads;
    use warnings;
    use Socket;
    use IO::Handle;
    
    sub new {
        my ($self, %args) = @_;
        socket(my $sock, PF_INET, SOCK_STREAM, 0)
            or die "$0: Can't create socket: $!";
        bless {
            sock => $sock, %args
        }, $self;
    }
    
    sub connect {
        my ($self, %args) = @_;
        my $host = $args{host} || $self->{host} || die "$0: No host to connect";
        my $port = $args{port} || $self->{port} || die "$0: No port to connect";
        my $sock = $self->{sock};
        connect($sock, pack_sockaddr_in($port, inet_aton($host)))
            or die "$0: Can't connect to $host:$port : $!";
        $self->{io} = IO::Handle->new;
        $self->{io}->fdopen(fileno($sock), "r+");
        $self
    }
    
    sub read_until {
        my ($self, $endl) = @_;
        my $data = "";
        do {
            eval {
                $data .= $self->{io}->getc;
            };
            last if $@;
        } until ($data =~ /$endl$/);
        $data
    }
    
    sub readline {
        my ($self) = @_;
        return $self->{io}->getline();
    }
    
    sub send {
        my ($self, $data) = @_;
        eval {
            $self->{io}->write($data, length($data));
            $self->{io}->flush();
        };
        $self
    }
    
    sub interactive {
        my ($self) = @_;
        async {
            while (!($self->{io}->eof)) {
                eval {
                    print $self->readline() || last;
                };
                last if $@;
            }
            threads->self()->join();
        };
        while (!eof(STDIN))
        {
            eval {
                my $line = <STDIN>;
                $self->send($line);
            };
            last if $@;
        }
        $_->join() for threads->list(threads::all);
    }
}

1;
