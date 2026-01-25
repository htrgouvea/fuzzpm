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
        my ($class, $seed) = @_;

        GetOptions (
            's|seed=s' => \$seed
        );

        if (!defined $seed || length $seed == 0) {
            return 0;
        }

        my $initial_seed_length = length $seed;
        my @operations = qw(bit_flip byte_overwrite byte_insert token_insert splice byte_delete);

        if ($initial_seed_length <= 1) {
            @operations = grep { $_ ne 'byte_delete' && $_ ne 'splice' } @operations;
        }

        my $operation = $operations[int rand @operations];

        if ($operation eq 'bit_flip') {
            my @bytes = unpack 'C*', $seed;
            my $byte_index = int rand @bytes;
            my $bit = 1 << int rand $BYTE_BITS;

            $bytes[$byte_index] ^= $bit;

            return pack 'C*', @bytes;
        }

        if ($operation eq 'byte_overwrite') {
            my @bytes = unpack 'C*', $seed;
            my $byte_index = int rand @bytes;

            $bytes[$byte_index] = int rand $BYTE_RANGE;

            return pack 'C*', @bytes;
        }

        if ($operation eq 'byte_insert') {
            my @bytes = unpack 'C*', $seed;
            my $byte_index = int rand(@bytes + 1);
            my $byte = int rand $BYTE_RANGE;

            splice @bytes, $byte_index, 0, $byte;

            return pack 'C*', @bytes;
        }

        if ($operation eq 'byte_delete') {
            my @bytes = unpack 'C*', $seed;

            if (@bytes <= 1) {
                return $seed;
            }

            my $byte_index = int rand @bytes;
            splice @bytes, $byte_index, 1;

            return pack 'C*', @bytes;
        }

        if ($operation eq 'splice') {
            my @bytes = unpack 'C*', $seed;
            my $byte_count = @bytes;

            if ($byte_count <= 1) {
                return $seed;
            }

            my $max_chunk = $MAX_SPLICE_CHUNK;
            if ($byte_count < $MAX_SPLICE_CHUNK) {
                $max_chunk = $byte_count;
            }
            my $chunk_length = 1 + int rand $max_chunk;
            my $start_index = int rand($byte_count - $chunk_length + 1);
            my @chunk = splice @bytes, $start_index, $chunk_length;
            my $insert_position = int rand(@bytes + 1);

            splice @bytes, $insert_position, 0, @chunk;

            return pack 'C*', @bytes;
        }

        if ($operation eq 'token_insert') {
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

            my $token = $tokens[int rand @tokens];
            my $insert_seed_length = length $seed;
            my $insert_position = int rand($insert_seed_length + 1);

            my $prefix = substr $seed, 0, $insert_position;
            my $suffix = substr $seed, $insert_position;

            return $prefix . $token . $suffix;
        }

        return $seed;
    }
}

1;
