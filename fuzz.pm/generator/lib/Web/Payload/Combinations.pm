package Web::Payload::Combinations {
    use strict;
    use warnings;
    use parent 'Exporter';

    our @EXPORT = qw(combinations);

    sub new {
        my ($self, $len, @list) = @_;
        die "Invalid length ($len)" if $len < 1;
        bless {
            length  => $len,
            symbols => [ @list ],
            current => "",
            iterate => __combinations($len, @list),
        }
    }

    sub next_payload {
        my ($self) = @_;
        $self->{current} = $self->{iterate}->();
        defined($self->{current});
    }

    sub get_payload {
        my ($self) = @_;
        $self->{current}
    }

    sub reset {
        my ($self) = @_;
        delete $self->{iterate};
        $self->{iterate} = __combinations($self->{length}, @{$self->{symbols}});
    }

    sub __combinations {
        my ($len, @list) = @_;
        my @index = map { 0 } 1 .. $len;
        my $ended = 0;
        return sub {
            return undef if $ended or @list < 1;
            my $comb = join "", @list[@index];
            $ended = 1 if $comb eq $list[-1] x @index;
            for (my $i = @index - 1; $i >= 0; $i --) {
                $index[$i] ++;
                last unless $index[$i] >= @list;
                $index[$i] = 0;
            }
            return $comb;
        }
    }

}

1
