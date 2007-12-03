#!/usr/bin/perl -w
# search for trades missing from public CSV data after 20h

use strict;
use awstandard;
use awinput;
use DBAccess;
use LWP::Simple;

my $players=$dbh->selectall_arrayref("SELECT pid FROM player WHERE trade-otr>7");

if(!$players || !@$players || $interbeta || @$players>500) { # sanity check for inter-round
   exit 0;
}
print STDERR "$0 updating ",scalar @$players, "\n";
#open(STDOUT, ">/dev/null");
open(STDERR, ">/dev/null");
#close STDOUT; close STDERR;


foreach(@$players) {
   my($pid)=@$_;
   print " $pid=".playerid2namem($pid);
#   system("/usr/bin/wget","-O/dev/null","http://aw21.zq1.de/about/playerprofile.php?id=".$pid);
   get("http://aw21.zq1.de/about/playerprofile.php?id=".$pid);
}

if(1) {
   system("hourly/otr.pl");
}

