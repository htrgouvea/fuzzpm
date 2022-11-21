package Utils::FileIterator {
    use strict;
    use warnings;
    
    sub new
    {
        my ($self, $filename, $loop, $encoding) = @_;
        $encoding = $encoding ? ":encoding($encoding)" : "";
        open(my $handler, "<$encoding", $filename)
            || die "$0: Can't open $filename: $!";
        return sub
        {
            #if on loop, try returning to the beginning of the file when it
            #reaches the end
            eval { seek($handler, 0, 0) } if $loop && eof($handler);
            #if we reach the end of the file at this point, the iterator is done
            return undef if eof($handler);
            chomp(my $line = <$handler>);
            $line;
        }
    }
}

1;
