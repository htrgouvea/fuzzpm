#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use YAML::Tiny;
use Mojo::File;
use Getopt::Long;
use Path::Iterator::Rule;
use Data::Dumper;

sub main {
    my ($rules, $source);

    Getopt::Long::GetOptions (
        "r|rules=s"  => \$rules,
        "s|source=s" => \$source
    );

    if ($rules) {
        my $yamlfile = YAML::Tiny -> read($rules);
 	    my $list     = $yamlfile -> [0];
        my $files    = Path::Iterator::Rule -> new($source) -> file() -> not_empty();
    
        $files -> skip_dirs(".git") -> file();
        $files -> name("*.pl", "*.pm", "*.t");

        for my $file ($files -> all(@ARGV)) {
            my $resources = Mojo::File -> new($file);
            my @source    = $resources -> slurp();
            
            print Dumper($files);

            # if (grep {$_ =~ m/"$test"/} @source) {
            #     print "[+] $file in the guest list\n";
            # } 
        }
    }
}

exit main();