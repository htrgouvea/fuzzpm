package Utils::URI {

    use strict;
    use warnings;
    use parent 'URI::URL';
    use Data::Dumper;

    sub __get_params
    {
        my ($self) = @_;
        my %params = map {
            my ($key, $value) = split /=/, $_;
            $key => $value || ''
        } split /&/, ($self->equery || '');
        %params;
    }
    
    sub param
    {
        my ($self, %hash) = @_;

        my %params = $self->__get_params();
        
        while (my ($key, $value) = each %hash)
        {
            $params{$key} = $value;
        }
        
        my $query = join( "&", map { $_ . "=" . $params{$_} } keys %params );
        
        $self->query( $query || $self->equery || '');
        $self
    }


    sub param_names
    {
        my ($self) = @_;
        my %p = $self->__get_params();
        (keys %p);
    }
    
    sub param_get
    {
        my ($self, @names) = @_;
        my %p = $self->__get_params();
        @p{@names}
    }
}

1;
