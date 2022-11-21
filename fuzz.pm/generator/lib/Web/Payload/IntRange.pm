package Web::Payload::IntRange {
    use strict;
    use warnings;
    use parent 'Web::Payload::Source';
    
    sub new {
        my ($self, $start, $stop, $step) = @_;
        bless {
            start   => $start,
            stop    => $stop,
            step    => $step,
            current => $start - $step,
        }, $self
    }

    sub next_payload {
        my ($self) = @_;
        $self->{current} += $self->{step};
        $self->{current} <= $self->{stop};
    }

    sub reset {
        my ($self) = @_;
        $self->{current} = $self->{start} - $self->{step};
    }

    sub get_payload {
        my ($self) = @_;
        $self->{current}
    }

}

1;
