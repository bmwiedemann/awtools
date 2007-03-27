#!/usr/bin/perl -w
# this code is Copyright Bernhard M. Wiedemann and licensed under GNU GPL
use strict;
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
      my $aid=playerid2alliance($pid);
      if($aid) {push(@droplist,$k);next} # drop tagged players
   }
   foreach my $k (@droplist) {
      print "dropped $k = $alliuser{$k}\n";
      delete $alliuser{$k};
   }
}

