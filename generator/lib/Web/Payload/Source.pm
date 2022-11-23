package Web::Payload::Source {
    
    use strict;
    use warnings;
   
    #use overload "<>" => \&iterate;

    sub new {
        my ($self, %options) = @_;
        bless {
            %options
        }, $self
    }

    sub next_payload {

    }

    sub reset {

    }
    
    sub get_payload {

    }
    
    sub iterate {
        my ($self, @extra) = @_;
        $self->next_payload() ? $self->get_payload() : undef;
    }
}

1;
