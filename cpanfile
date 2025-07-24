requires 'YAML::Tiny',      '1.76';
requires 'List::MoreUtils', '0.430';
requires 'Getopt::Long',    '2.58';
requires 'Find::Lib',       '1.04';

on 'test' => sub {
    requires 'File::Temp',          '0.2311';
    requires 'FindBin',             '1.54';
    requires 'IO::CaptureOutput',   '1.1105';
}
