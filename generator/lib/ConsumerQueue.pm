package ConsumerQueue {
    use strict;
    use warnings;
    use threads::shared;
    use parent 'Thread::Queue';

    sub iterators {
        my ($self, @new) = @_;
        lock(%$self);
        @{$self->{queue}} = map { shared_clone($_) } @new if @new;
        return @{$self->{queue}};
    }
    
    sub clear {
        my ($self) = @_;
        lock(%$self);
        @{$self->{queue}} = ();
    }
    
    sub __next {
        my ($self) = @_;
        my $queue = $self->{queue};
        cond_wait(%$self) while (@$queue < 1) && ! $$self{'ENDED'});
        return @$queue > 0 ? $queue->[0] : undef
    }
    
    sub dequeue {
        my ($self, $count) = @_;
        lock(%$self);
        $count = 1 unless $count;
        my @items;
        while (@items < $count)
        {
            my $iter = $self->__next();
            my $item = $iter->();
            unless(defined($item))
            {
                shift @{$queue};
                $iter = $self->__next() || last;
                next
            }
            push @items, $item;
        }
        cond_signal(%$self);
        return $items[0] if @items == 1;
        @items > 1 ? @items : undef
    }
}
1;
