requires 'YAML::Tiny',      '1.76';
requires 'List::MoreUtils', '0.430';
requires 'Getopt::Long',    '2.58';
requires 'Readonly', '2.05';
requires 'Try::Tiny';

on 'test' => sub {
    requires 'File::Temp',          '0.2311';
    requires 'FindBin',             '1.54';
}
