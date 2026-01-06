package FuzzPM::Component::Mutator {
    use strict;
    use warnings;
    use bytes;
    use Getopt::Long;

    our $VERSION = '0.0.4';

    sub new {
        my ($self, $seed) = @_;

        GetOptions (
            's|seed=s' => \$seed
        );

        if (!defined $seed || length($seed) == 0) {
            return 0;
        }

        my $len = length $seed;
        my @ops = qw(bit_flip byte_overwrite byte_insert token_insert splice byte_delete);

        if ($len <= 1) {
            @ops = grep { $_ ne 'byte_delete' && $_ ne 'splice' } @ops;
        }

        my $op = $ops[int rand @ops];

        if ($op eq 'bit_flip') {
            my @bytes = unpack 'C*', $seed;
            my $index = int rand @bytes;
            my $bit   = 1 << int rand 8;

            $bytes[$index] ^= $bit;

            return pack 'C*', @bytes;
        }

        if ($op eq 'byte_overwrite') {
            my @bytes = unpack 'C*', $seed;
            my $index = int rand @bytes;

            $bytes[$index] = int rand 256;

            return pack 'C*', @bytes;
        }

        if ($op eq 'byte_insert') {
            my @bytes = unpack 'C*', $seed;
            my $index = int rand(@bytes + 1);
            my $byte  = int rand 256;

            splice @bytes, $index, 0, $byte;

            return pack 'C*', @bytes;
        }

        if ($op eq 'byte_delete') {
            my @bytes = unpack 'C*', $seed;

            return $seed if @bytes <= 1;

            my $index = int rand @bytes;
            splice @bytes, $index, 1;

            return pack 'C*', @bytes;
        }

        if ($op eq 'splice') {
            my @bytes = unpack 'C*', $seed;
            my $count = @bytes;

            return $seed if $count <= 1;

            my $max_chunk  = $count < 8 ? $count : 8;
            my $chunk_len  = 1 + int rand $max_chunk;
            my $start      = int rand($count - $chunk_len + 1);
            my @chunk      = splice @bytes, $start, $chunk_len;
            my $insert_pos = int rand(@bytes + 1);

            splice @bytes, $insert_pos, 0, @chunk;

            return pack 'C*', @bytes;
        }

        if ($op eq 'token_insert') {
            my @tokens = (
                "\x00",
                "\n",
                "\r\n",
                'A',
                'AAAA',
                '0',
                '1',
                '../',
                '..\\',
                '%s',
                '%n',
                q{"},
                q{'},
                '<',
                '>',
                '(',
                ')',
                '{',
                '}',
                '[',
                ']',
                q{\\},
                '/',
                ' ',
            );

            my $token = $tokens[int rand @tokens];
            my $pos   = int rand(length($seed) + 1);

            return substr($seed, 0, $pos) . $token . substr($seed, $pos);
        }

        return $seed;
    }
}

1;
