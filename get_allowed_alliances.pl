#!/usr/bin/perl
use strict;
use warnings;
use awaccess;

while(my @a=each %allowedalli) {
   next if not $a[1];
   print "$a[0]\n";
}
