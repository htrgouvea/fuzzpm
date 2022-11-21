package Web::Payload::Wordlist {

    use strict;
    use warnings;
    use parent 'Web::Payload::Source';

    sub new {
        my ($self, $filename) = @_;
        open(my $fhandler, "<$filename") ||
            die "$0: Can't open $filename for reading: $!";
        bless {
            filename => $filename,
            fhandler => $fhandler,
        }, $self
    }

    sub next_payload {
        my ($self) = @_;
        eof(my $fh = $self->{fhandler}) && return 0;
        chomp($self->{current} = <$fh>);
        1;
    }

    sub reset {
        my ($self) = @_;
        seek $self->{fhandler}, 0, 0; 
    }

    sub get_payload {
        my ($self) = @_;
        $self->{current};
    }
}

1;
   
   
