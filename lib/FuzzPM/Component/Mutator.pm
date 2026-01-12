package FuzzPM::Component::Mutator {
    use strict;
    use warnings;
    use bytes;
    use Getopt::Long;
    use Readonly;

    our $VERSION = '0.0.4';
    Readonly my $BYTE_BITS        => 8;
    Readonly my $BYTE_RANGE       => 256;
    Readonly my $MAX_SPLICE_CHUNK => 8;

    sub new {
        my ($self, $seed) = @_;

        GetOptions (
            's|seed=s' => \$seed
        );

        if (!defined $seed || length $seed == 0) {
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
            my $bit   = 1 << int rand $BYTE_BITS;

            $bytes[$index] ^= $bit;

            return pack 'C*', @bytes;
        }

        if ($op eq 'byte_overwrite') {
            my @bytes = unpack 'C*', $seed;
            my $index = int rand @bytes;

            $bytes[$index] = int rand $BYTE_RANGE;

            return pack 'C*', @bytes;
        }

        if ($op eq 'byte_insert') {
            my @bytes = unpack 'C*', $seed;
            my $index = int rand(@bytes + 1);
            my $byte  = int rand $BYTE_RANGE;

            splice @bytes, $index, 0, $byte;

            return pack 'C*', @bytes;
        }

        if ($op eq 'byte_delete') {
            my @bytes = unpack 'C*', $seed;

            if (@bytes <= 1) {
                return $seed;
            }

            my $index = int rand @bytes;
            splice @bytes, $index, 1;

            return pack 'C*', @bytes;
        }

        if ($op eq 'splice') {
            my @bytes = unpack 'C*', $seed;
            my $count = @bytes;

            if ($count <= 1) {
                return $seed;
            }

            my $max_chunk = $MAX_SPLICE_CHUNK;
            if ($count < $MAX_SPLICE_CHUNK) {
                $max_chunk = $count;
            }
            my $chunk_len  = 1 + int rand $max_chunk;
            my $start      = int rand($count - $chunk_len + 1);
            my @chunk      = splice @bytes, $start, $chunk_len;
            my $insert_pos = int rand(@bytes + 1);

            splice @bytes, $insert_pos, 0, @chunk;

            return pack 'C*', @bytes;
        }

        if ($op eq 'token_insert') {
            my @tokens = (
                chr 0,
                "\n",
                "\r\n",
                'A',
                'AAAA',
                '0',
                '1',
                q{../},
                q{..\\},
                q{%s},
                q{%n},
                q{"},
                q{'},
                q{<},
                q{>},
                q{(},
                q{)},
                q[{],
                q[}],
                q{[},
                q{]},
                q{\\},
                q{/},
                q{ },
            );

            my $token    = $tokens[int rand @tokens];
            my $seed_len = length $seed;
            my $pos      = int rand ($seed_len + 1);

            my $prefix = substr $seed, 0, $pos;
            my $suffix = substr $seed, $pos;

            return $prefix . $token . $suffix;
        }

        return $seed;
    }
}

1;
