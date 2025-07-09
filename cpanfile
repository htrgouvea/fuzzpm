requires "YAML::Tiny", "1.73";
requires "List::MoreUtils", "0.428";
requires "Getopt::Long", "2.58";
requires "Find::Lib", "1.04";

on "test" => sub {
    requires "IO::CaptureOutput", "1.1105";
}
