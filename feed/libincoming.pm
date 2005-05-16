
sub parseincomings($) {local $_=$_[0];
my @a;
for(;(@a=m!([^>]*)</td><td[^>]*>\s*<b>Attention(.*?) going to attack <b>([^<]+)</b>.<br>We suppose its the Fleet of <a href=/0/Player/Profile.php/\?id=(\d+)>([^<]+)</a>((?:[^>]*</td><td[^>]*> <b>Attention)?.*)!);$_=$a[5]) {
	my @fleet=(0,0,0,0,0);
	my $pid=$a[3];
	my $sid;
	my $enemyname=$a[4];
	my $shipn=0;
	foreach my $ship (qw(Transports Colony Destroyer Cruiser Battleship)) {
		if($a[1]=~/(\d+) $ship/) {
			$fleet[$shipn]=$1;
		}
		$shipn++;
	}
	my $time=parseawdate($a[0]);
	if($a[2]=~/(.+) (\d+)$/) {
		$sid=systemname2id($1);
		if($sid){$sid.="#$2"}
	}
	if(!$sid) {next}
	my $oldentry=$::data{$sid};
	print "incoming: ".planetlink($sid)." @fleet<br>\n";
	my $newentry=addfleet($oldentry,$pid, $enemyname, $time, 1, \@fleet);
	if(!$::options{debug}){$::data{$sid}=$newentry;}
	else {print "$sid $newentry<br>\n"}
}
}
1;
