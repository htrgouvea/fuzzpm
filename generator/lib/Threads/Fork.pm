package Threads::Fork {
    use strict;
    use warnings;
    use base 'Exporter';
    use POSIX ":sys_wait_h";

    our @EXPORT = qw(async);
    
    my %processes;    
    
    $SIG{CHLD} = sub {
        while ((my $child = waitpid(-1, WNOHANG)) > 0)
        {
            delete $processes{$child};
        };
    };
    
    sub new {
        my ($self, $coderef, @args) = @_;
        die "Invalid coderef" unless defined($coderef) && ref($coderef) eq "CODE";
        my $pid = fork();
        die "Can't fork: $!" unless defined($pid);
        $processes{$pid} = $coderef if $pid;
        if ($pid == 0)
        {
            $coderef->(@args);
            exit(0);    
        }
        $pid
    }
    
    sub async (&;@) {
        my $coderef = shift;
        Threads::Fork->new($coderef);
    }
    
    sub create {
        my ($self, $coderef, @args) = @_;
        Threads::Fork->new($coderef, @args);
    }
    
    sub wait_children {
        my ($self) = @_;
        $self->wait_for(keys %processes);
    }

    sub wait_for {
        my ($self, @pids) = @_;
        for my $pid (@pids) {
            1 while waitpid($pid, WNOHANG) > 0;
        }
    }
        
    sub list {
        my ($self) = @_;
        keys %processes
    }

}

1;
