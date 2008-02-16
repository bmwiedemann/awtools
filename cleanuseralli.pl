#!/usr/bin/perl -w
# this code is Copyright Bernhard M. Wiedemann and licensed under GNU GPL
use strict;
use DBAccess2;
use awstandard;
use awinput;
awinput_init(1);

if(!$interbeta) {
   my $dbh=get_dbh;
	my $userlist=$dbh->selectall_arrayref("SELECT `pid` FROM `useralli` ORDER BY `pid`");
   my @droplist=();
   foreach my $e (@$userlist) {
		my($kpid)=@$e;
		my($pid,$k)=get_one_row("SELECT `pid`,`name` FROM `player` WHERE `pid` = ? LIMIT 1", [$kpid]);
      if(!$pid) {push(@droplist,[$kpid,"*resigned*"]);next} # wipe non-existent players
      my $a=playerid2tag($pid);
      if(lc($k) eq "klappstuhl") {next}
      if($a) {push(@droplist,[$pid,$k]);next} # drop tagged players
   }
   my $sth=$dbh->prepare("DELETE FROM `useralli` WHERE pid = ?");
   foreach my $e (@droplist) {
		my($pid,$k)=@$e;
      print "dropped $pid=$k\n";
      $sth->execute($pid);
   }
}

