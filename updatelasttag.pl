#!/usr/bin/perl -w
use strict;
use DBAccess;

my $tags=$dbh->selectall_arrayref("SELECT pid,player.name,tag FROM player,alliances WHERE aid=alliance");


my $sth=$dbh->prepare("UPDATE `playerextra` SET lasttag=? WHERE pid=? AND name=?");
foreach my $t (@{$tags}) {
   my($pid,$name,$tag)=@$t;
   next if not $tag;
#   print "@$t\n";
  $sth->execute($tag,$pid,$name);
}

