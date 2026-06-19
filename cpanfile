requires 'YAML::Tiny',      '1.76';
requires 'List::MoreUtils', '0.430';
requires 'Getopt::Long',    '2.58';
requires 'Readonly', '2.05';
requires 'Math::Random::Secure', '0.080001';
requires 'Try::Tiny', '0.32';

on 'test' => sub {
    requires 'FindBin',    '1.54';
    requires 'Test::More', '1.302222';
}
