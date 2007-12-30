#!/usr/bin/perl -w
use strict;
use DBAccess;


my $ar=$dbh->selectall_arrayref("
      SELECT useralli.pid, player.name, useralli.alli
      FROM `useralli`,`player`
      WHERE useralli.`pid` = player.`pid`
   ");

foreach my $row (@$ar) {
   print join("\t=",@$row)."\n";
}
