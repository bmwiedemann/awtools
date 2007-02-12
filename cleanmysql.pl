#!/usr/bin/perl -w
# this code is Copyright Bernhard M. Wiedemann and licensed under GNU GPL
use strict;
use DBAccess;

my $now=time();
my $time=$now-36*3600;
$dbh->do("DELETE FROM `usersession` where `lastclick` < ".$time);

my $time2=$now-30*3600;
$dbh->do("DELETE FROM `fleets` where `lastseen` < ".$time2);

$dbh->do("OPTIMIZE TABLE `fleets`");
$dbh->do("OPTIMIZE TABLE `usersession`");
