#!/usr/bin/perl -w
# this code is Copyright Bernhard M. Wiedemann and licensed under GNU GPL
use strict;
use DBAccess2;
use awstandard;
use awinput;
use Fcntl qw(:flock O_RDWR O_CREAT O_RDONLY);
awinput_init(1);

if(!$interbeta) {
   my %alliuser;
   awinput::opendb(O_RDWR, "$awstandard::dbmdir/useralli.dbm", \%alliuser);
   my @droplist=();
   foreach my $k (keys %alliuser) {
      my $pid=playername2id($k);
      if(!$pid) {push(@droplist,$k);next} # wipe non-existent players
      my $a=playerid2tag($pid);
      if(lc($k) eq "klappstuhl") {next}
      if($a) {push(@droplist,$k);next} # drop tagged players
   }
   my $dbh=get_dbh;
   my $sth=$dbh->prepare("DELETE FROM `useralli` WHERE pid = ?");
   foreach my $k (@droplist) {
      print "dropped $k = $alliuser{$k}\n";
      delete $alliuser{$k};
      my $pid=playername2idm($k);
      next if ! $pid;
      $sth->execute($pid);
   }
}

