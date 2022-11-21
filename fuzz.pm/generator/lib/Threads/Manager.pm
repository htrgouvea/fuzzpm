package Threads::Manager {
    use strict;
    use threads;
    use warnings;
    
    sub new {
        my ($self, $coderef) = @_;
        die "No coderef" unless $coderef;
        bless { coderef => $coderef }, $self;
    }
    
    sub run {
        my ($self, $tasks) = @_;
        async {
            $self->{coderef}->($_);
        } for 1 .. $tasks || 1;
        $self
    }
    
    sub stop {
        my ($self) = @_;
        map { $_->join() } threads->list(threads::all);
    }
    
    sub wait_all {
        my ($self, $callback) = @_;
        while (threads->list(threads::running) > 0)
        {
            $callback->() if $callback;
        }
        $self->stop()
    }
}

1;
