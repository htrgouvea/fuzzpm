package Threads::ForkQueue {
    use strict;
    use threads;
    use warnings;
    use File::Temp;
    use IO::Select;
    use Threads::Fork;
    use threads::shared;
    use IO::Socket::UNIX;
    use Fcntl qw(:DEFAULT :flock);

    sub __server_loop {
        my ($sockfile, @queue) = @_;

        my $server = IO::Socket::UNIX->new(
            Type => SOCK_STREAM(),
            Local => $sockfile,
            Listen => 10,
        );

        my $select = IO::Select->new($server);
        
        my @read :shared;
        
        threads::async {
            while (1) {
                last unless -f $sockfile;
                lock(@read);
                for my $ready (@read) {
                    
                }
            }
        };
        
        while (1) {
            READ: {
                lock(@read);
                @read = $select->can_read();
            }
            my @write = $select->can_write();
            
        }
            foreach my $socket ($select->can_read()) {
                if ($socket == $server) {
                    $select->add($socket->accept());
                }
                else
                {
                    next if (-e "$sockfile.lock");
                    chomp(my $value = <$server>);
                    push @queue, $value;
                }
            }
            
            my @read = $select->can_read();
            my @write = $select->can_write();
            $select->add($server->accept()) for 1 .. grep(/^$server$/, @read, @write);
            
            foreach my $socket ($select->can_write()) {
                if ($socket == $server) {
                    $select->add($socket->accept());
                }
                else
                {
                    if (@queue < 1) {
                        if (-f "$sockfile.lock") {
                            $server->close();
                            last SERVERLOOP;
                        }
                    }
                    print $socket shift @queue, "\n";
                }
            }
        }
    }
    
    sub new {
        my ($self, @values) = @_;
        my $sockfile = "${\tmpnam()}.threads_forkqueue_${\time()}.sock";
        Threads::Fork::async { __server_loop($sockfile, @values) };
        bless { sockfile => $sockfile }, $self
    }
    
    sub enqueue {
        my ($self, @values) = @_;
        unless ($self->{client}) {
            eval {
                $self->{client} = IO::Socket::UNIX->new(
                    Type => SOCK_STREAM(),
                    Peer => $self->{sockfile}
                );
            } || return undef;
        }
        my $fh = $self->{client};
        print $fh "$_\n" for @values;
    }

    sub dequeue {
        my ($self) = @_;
        unless ($self->{client}) {
            eval {
                $self->{client} = IO::Socket::UNIX->new(
                    Type => SOCK_STREAM(),
                    Peer => $self->{sockfile}
                );
            } || return undef;
        }
        my $fh = $self->{client};
        my $value = <$fh>;
        chomp($value) if $value;
        return $value;
    }
    
    sub end {
        my ($self) = @_;
        my $sockfile = $self->{sockfile};
        eval {
            sysopen my $fh, "$sockfile.lock", O_WRONLY|O_EXCL|O_CREAT || return;
            flock($fh, LOCK_EX);
            print $fh "LOCKED";
            close $fh;
        }
    }
}

1
