package parse::libincoming;
use awstandard;

sub parse_incoming($)
{
	my $html=shift;
	if($html=~m{<td class="incoming">\s*($awstandard::awdatere)<br />.*?>Attention !!!(.*?)going to attack <a href[^>]+>ID (\d+) - ([^#]+) \#(\d+)</a><br/>\s*We suppose it's the fleet of <a href="\.\./Player/Profile.php\?id=(\d+)">(?:\[[A-Z]+\])?([^<]+)</a>\.}s) {
		my($awdatetime,$fleet, $sid, $systemname, $pid,$playerid,$playername)=($1,$2,$3,$4,$5,$6,$7);
		my @fleet=(0,0,0,0,0);
		@shipname=qw(transport colony destroyer cruiser battleship);
		for my $n (0..4) {
			$fleet=~m/(\d+) $shipname[$n]/i and $fleet[$n]=$1;
		}
		my $time=parseawdate($awdatetime); # is local time
		#return "$time $awdatetime,@fleet $fleet, $sid, $systemname, $pid,$playerid,$playername"; #debug
		return {eta=>$time, ship=>\@fleet, sid=>$sid, pid=>$pid, system=>$systemname, ownerid=>$playerid, ownername=>$playername};
	}
	# GE27 beta format
	$html=~m{<td class="incoming">\s*($awstandard::awdatere)<br />\s*.*index.php\?destroyer=(\d+)&amp;cruiser=(\d+)&amp;battleship=(\d+).*\b(\d+) TR(?:</span>)?\s*(?:(\d+) CS\s*)?-.*<a href="\.\./Map/Detail\.php\?nr=(\d+)">ID \d+ - ([^#]+) #(\d+)</a><br />\s*(?:<span class="\w+">)?<a href="\.\./Player/Profile\.php\?id=(\d+)">(?:\[\w+\])? *([^<]+)</a>}s or return;
	my ($awdatetime,$sid,$systemname, $pid,$playerid,$playername)=($1,$7,$8,$9,$10,$11);
	my @fleet=($5,$6||0, $2,$3,$4);
	my $time=parseawdate($awdatetime); # is local time
	return {eta=>$time, ship=>\@fleet, sid=>$sid, pid=>$pid, system=>$systemname, ownerid=>$playerid, ownername=>$playername};
}

1;
