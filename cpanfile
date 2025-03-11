requires "YAML::Tiny";
requires "List::MoreUtils";
requires "Getopt::Long";
requires "Find::Lib";

on "test" => sub {
    requires "IO::CaptureOutput";
}