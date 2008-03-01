#!/usr/bin/perl
use warnings;
use strict;
use DBAccess;

my $a=shift;

foreach my $n (qw(fleets relations logins planetinfos intelreport plhistory)) {
   $dbh->do("DELETE
      FROM `$n`
      WHERE `alli` = '$a'");
}

system("rm -r html/alli/$a");

