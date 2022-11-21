#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use PPI;
use Data::Dumper;
use PPI::Document;
use PPI::Dumper;

sub main {
    my $document = PPI::Document -> new("lib/Spellbook/Helper/CDN_Checker.pm");

    my $Module = PPI::Document -> new("lib/Spellbook/Helper/CDN_Checker.pm");
    my $Dumper = PPI::Dumper -> new ($Module);

    $Dumper -> print;

    # Does it contain any POD?
    my $pkg = $document -> find_first('PPI::Statement::Package') -> namespace;
    print $pkg;
}

main();