package Utils::Combinations {
    use strict;
    use warnings;
    use parent 'Exporter';

    our @EXPORT = qw(combinations);
    
    sub combinations {
        my ($len, @list) = @_;
        die "Invalid length" if $len < 1;
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
