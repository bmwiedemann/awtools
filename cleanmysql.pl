#!/usr/bin/perl -w
# this code is Copyright Bernhard M. Wiedemann and licensed under GNU GPL
use strict;
use DBAccess;

my $now=time();
my $time=$now-48*3600;
$dbh->do("DELETE FROM `usersession` WHERE `lastclick` < ".$time);

my $time2=$now-36*3600;
$dbh->do("DELETE FROM `fleets` WHERE `lastseen` < ".$time2);

my $time3=$now-14*24*3600;
$dbh->do("DELETE FROM `imessage` WHERE `time` < ".$time3);

my $time4=$now-8*3600;
$dbh->do("DELETE FROM cdcv WHERE pid = 0 OR time < $time"); # delete outdated entries
$dbh->do("DELETE FROM cdlive WHERE time < $time");


foreach my $t (qw(fleets usersession battles imessage cdcv cdlive)) {
   $dbh->do("OPTIMIZE TABLE `$t`");
}
