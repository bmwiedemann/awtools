my $debug=$::options{debug};
if($debug) {print "debug mode - no modifications done<br>\n"}
my $name=$::options{name};

if(0){
	local $_=$_;
	my $dplayerid=playername2id($name);
	if(!$dplayerid) {
		print "error, unknown reporting player: '$name'\n";
		return 1;
	}
	for(;(@a=m!<tr[^>]*><td[^>]*>([^>]*)</td><td[^>]*>Your attacking fleet was defeated by <a href=/0/Player/Profile.php/\?id=(\d+)>([^>]*)</a> [^>]*You killed about (\d+)%.</td></tr>(.*)!); $_=$a[4]) {
		my ($time,$pid,$splayer,$amount)=@a;
		$time=parseawdate($time);
		$splayerid=playername2id($splayer);
		print gmtime($time)." $pid $splayer($splayerid)-&gt;$name($dplayerid) $amount%<br />\n";
		if(!$splayerid) {
			print "unknown player $splayer\n";
			next;
		}
		if(!$debug) {
#dbtransferadd($time,$splayerid,$dplayerid,$amount,int($amount/2));
		} else { print "not added".br}
	}
}

dbfleetaddinit(undef, 0);
require 'feed/libincoming.pm';
parseincomings($_);
dbfleetaddfinish();
1;
