#!/usr/bin/perl
use strict;
use warnings;
use awaccess;

my $a=getallowedallis();
foreach my $alli(@$a) {
   print "$alli\n";
}
