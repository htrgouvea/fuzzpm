package Web::Request::Parameter {
    use strict;
    use warnings;
    use URI::Escape;
    use parent 'Exporter';
    use overload '==' => \&equals;
        
    our @EXPORT = qw(P_URL P_COOKIE P_HEADER);
    
    use constant {
        P_URL       => 0,
        P_COOKIE    => 1,
        P_HEADER    => 2,
    };
    
    sub new {
        my ($self, $name, $type, $preset, $source) = @_;
        bless {
            name => $name,
            type => $type,
            orig => $preset,
            value => $preset,
            source => $source
        }, $self;
    }
    
    sub name {
        my ($self, $name) = @_;
        $self->{name} = $name if $name;
        $self->{name}
    }
    
    sub value {
        my ($self, $value) = @_;
        $self->{value} = $value if $value;
        uri_escape($self->{value} || return undef)
    }
    
    sub type {
        my ($self, $type) = @_;
        $self->{type} = $type if $type;
        $self->{type}
    }
    
    sub reset {
        my ($self) = @_;
        $self->{value} = $self->{orig};
        $self
    }
  
    sub next_val {
        my ($self) = @_;
        $self->{value} = $self->{source}->();
    }
    
    sub ended {
        my ($self) = @_;
        defined($self->{value});
    }
    
    sub equals {
        my ($self, $other) = @_;
        ($self->{name} eq $other->{name}) && ($self->{type} eq $other->{type})
    }
}

1;
