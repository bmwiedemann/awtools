#!/usr/bin/perl -w
use strict;
use DBAccess;

my $list=$dbh->selectall_arrayref("
SELECT player.pid, playerextra.name, player.name
FROM `playerextra` , player
WHERE playerextra.pid = player.pid
AND player.name != playerextra.name");

foreach(@$list) {
   print "@$_\n";
}
