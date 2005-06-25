my $debug=$::options{debug};
print "news feed\n<br>";
if($debug) {print "debug mode - no modifications done<br>\n"}
my $name=$::options{name};

{
	require "input-mysql.pm";
	local $_=$_;
	my $pid=playername2id($name);
	if(!$pid) {
		print "error, unknown reporting player: '$name'\n";
		return;
	}
	for(;(@a=m!<tr[^>]*><td[^>]*>([^>]*)</td><td[^>]*>Your attacking fleet was defeated by <a href=/0/Player/Profile.php/\?id=(\d+)>([^>]*)</a> [^>]*You killed about (\d+)%.</td></tr>(.*)!); $_=$a[4]) {
		my ($time,$pid,$splayer,$amount)=@a;
		$time=parseawdate($time);
		print gmtime($time)." $pid $splayer-&gt;$name $amount%<br />\n";
		$splayerid=playername2id($splayer);
		if(!$splayerid) {
			print "unknown player $splayer\n";
			next;
		}
		if(!$debug) {
			dbtransferadd($time,$splayerid,$pid,$amount);
		} else { print "not added".br}
	}
}
require "input.pm";

dbfleetaddinit(undef);

require 'feed/libincoming.pm';
parseincomings($_);
1;
