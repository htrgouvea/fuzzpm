
#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;

my %account = (
    name => "", 
    money => 1000
);

sub buy_items {
    print "\n\n";
    
    my @items = (
        {name => "web hacking book", price => 100, id => 1},
        {name => "severino license", price => 50, id => 2},
        {name => "home made hacking tool", price => 200, id => 3},
        {name => "shell", price => 100000, id => 4}
    );
    
    foreach my $item (@items) {
        print "ID: @$item{id}\n";
        print "Product: @$item{name}\n";
        print "Price: @$item{price}\n\n";
    }

    print "\nItem ID? ";
    chomp (my $itemid = <STDIN>);

    if ($itemid > 0 && $itemid < 5) {
        print "\nHow many? ";
        chomp (my $many = <STDIN>);

        my $total = $items[$itemid - 1 ] -> {price} * $many;
        print "[+] TOTAL ===> $total\n";

        if ($many <= 0) {
            print ":/\n";
        }

        else {
            if ($total > $account{money}) {
                print "You do not have enough money :(\n";
            }

            else {
                $account{money} -= $total;
                print "You buy item",  $items[$itemid - 1 ] -> {name}, "\n";


                if ($items[$itemid] -> {name} eq "shell") {
                    system ("/bin/sh");
                }
            }
        }
    }

    else {
        print "Invalid!\n";
        exit();
    }
}

sub show_account_info {
    print "\n[-] Account info:\n[+] Name: $account{name} \n[+] Money: $account{money}\n";
}

sub main {
    print "\nWhat is your name? ";
    chomp ($account{"name"} = <STDIN>);

    while (1) {
        print "\n0. buy items \n1. show account info\n2. exit\n? ";
        chomp (my $choice = <STDIN>);
        
        if ($choice == 0) {
            buy_items();
        }

        elsif ($choice == 1) {
            show_account_info();
        }

        elsif ($choice == 2) {
            exit();
        }
    }
}

main();