
sub parseincomings($) {local $_=$_[0];
my @a;
for(;(@a=m!([^>]*)</td><td[^>]*>\s*<b>Attention(.*?) going to attack <b>[^<]+</b>\s*\[(\d+)\] (\d+)\!<br>We suppose its the Fleet of <a href=/0/Player/Profile.php/\?id=(\d+)>([^<]+)</a>.((?:[^>]*</td><td[^>]*> <b>Attention)?.*)!);$_=$a[6]) {
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
	$sid="$systemid#$planetid";
	print "incoming: ".planetlink($sid)." @fleet<br>\n";
   if(!$::options{debug}) {
      print "added";
      dbfleetadd($systemid,$planetid,$epid, $ename, $time, 1, \@fleet);
   }
}
}
1;
