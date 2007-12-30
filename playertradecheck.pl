#!/usr/bin/perl -w
# search for trades missing from public CSV data after 20h

use strict;
use awstandard;
use awinput;
use DBAccess;
use LWP::Simple;

#my $players=$dbh->selectall_arrayref("SELECT pid FROM player WHERE trade-otr>7");
my $players=$dbh->selectall_arrayref("
      SELECT player.pid
      FROM `tradelive`,`player`, `alltrades`
      WHERE player.pid=tradelive.pid 
        AND tradelive.trade-otr>7
        AND player.pid=pid1
      GROUP BY pid1
      HAVING COUNT(pid1)<5
");

if(!$players || !@$players || $interbeta || @$players>500) { # sanity check for inter-round
   exit 0;
}
print STDERR "$0 updating ",scalar @$players, "\n";
#open(STDOUT, ">/dev/null");
#open(STDERR, ">/dev/null");
#close STDOUT; close STDERR;


foreach(@$players) {
   my($pid)=@$_;
   print STDERR " $pid=".playerid2namem($pid);
#   system("/usr/bin/wget","-O/dev/null","http://aw21.zq1.de/about/playerprofile.php?id=".$pid);
   get("http://aw21.zq1.de/about/playerprofile.php?id=".$pid);
   sleep 1;
}

if(1) {
   system("hourly/otr.pl");
}

