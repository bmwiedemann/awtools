package feed::libincoming;
use awstandard;
use awinput;
use strict;

sub feedincomings($) {
	my $incoming=shift;
	foreach my $f (@$incoming) {
      my @fleet=@{$f->{ship}};
		my $time=$f->{eta};
      if($time<time-3600*6) {
			print "skipping past incoming";
			next;
		}
		my $systemid=$f->{sid};
		my $planetid=$f->{pid};
		my $ename=$f->{ownername};
		my $epid=$f->{ownerid};
		my $sid="$systemid#$planetid";
      print "incoming: ".planetlink($sid)." @fleet\n";
      print "<br>added $systemid#$planetid $epid $ename $time";
      if(!$::options{debug}) {
         my $res=dbfleetadd($systemid,$planetid,$epid, $ename, $time, 2, \@fleet);
         if(1 && $fleet[0]) {
#my @rel=getrelation("bananabird");
#        my $r=$rel[0]||1;
            print " important incoming of '$ename'";
         }
      }
      print "<br />";

	}
}
sub parseincomings($) {local $_=$_[0];
   my @a;
   for(;(@a=m!<tr[^>]*><td[^>]*>([^>]*)(?:<br>[^>]*)?</td><td[^>]*>\s*<b>Attention(.*?) going to attack <b>[^<]+</b>\s*\[(\d+)\] (\d+)\!<br>We suppose its the Fleet of <a href="?(?:http://[a-z0-9.]*)?/0/Player/Profile.php/\?id=(\d+)"?>([^<]+)</a>.((?:[^>]*</td><td[^>]*> <b>Attention)?.*)!);$_=$a[6]) {
      my ($awdatetime,$fleets,$systemid,$planetid,$epid,$ename)=@a;
#print join("<br />\n",@a[0..5]);
      my @fleet=(0,0,0,0,0);
      my $shipn=0;
      foreach my $ship (qw(Transports Colony Destroyer Cruiser Battleship)) {
         if($fleets=~/(\d+) $ship/) {
            $fleet[$shipn]=$1;
         }
         $shipn++;
      }
      my $time=parseawdate($awdatetime);
      if($time-3600*$::options{tz}<time-3600*6) {
         print "skipping past incoming";
      } else {
      my $sid="$systemid#$planetid";
      print "incoming: ".planetlink($sid)." @fleet\n";
      print "<br>added $systemid#$planetid $epid $ename $time";
      if(!$::options{debug}) {
         my $res=dbfleetadd($systemid,$planetid,$epid, $ename, $time, 2, \@fleet);
         if(1 && $fleet[0]) {
#my @rel=getrelation("bananabird");
#        my $r=$rel[0]||1;
            print " important incoming of '$ename'";
         }
      }
      }
      print "<br />";
   }
}

1;
