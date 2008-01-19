use strict;
use awparser;
use awstandard;

# fleets and planets
my @planets=();
my @movingfleet=();
foreach my $line (m{<tr align=center bgcolor=(.+?)</tr>}g) {
	if(my @a=($line=~m{^#(\d+)><td(?: title="([^"]*)")?>})) {
		my @extra=();
		if($a[0] eq "404040") {
			my @d=split("</td><td[^>]*>",$');
			my $sid=shift(@d);
			next if $sid eq "SID";
			my $pid=shift(@d);
			my $eta=parseawdate(shift(@d));
			my @ships=map {int($_)} @d;
			foreach my $n (0..4) { push(@extra, lc($awstandard::shipstr[$n]), $ships[$n])}
			push(@movingfleet, {sid=>$sid, pid=>$pid, eta=>$eta, ships=>\@ships, @extra});
			next;
		}
		my @d=split("</td><td>",$');
		my $siege;
		if($a[0] eq "303030") {
			$siege=0;
		} elsif($a[0] eq "602020") {
			$siege=1;
		} else {
#			$d->{debug}=$line;
			next;
		}
		my ($sid,$pid,$pop)=(shift(@d),shift(@d),shift(@d));
		my @ships=splice(@d, 5, 5);
		if($d[3] eq "N/A") { push(@extra, foreignplanet=>1); splice(@d,0,5); }
		foreach my $a (@ships) {$a+=0}
		foreach my $a (@d) {$a+=0}
		if(defined($d[0])) {
			foreach my $n (0..4) { push(@extra, lc($awstandard::buildingstr[$n]), $d[$n])}
		}
		foreach my $n (0..4) { push(@extra, lc($awstandard::shipstr[$n]), $ships[$n])}
		
		push(@planets, {sid=>int($sid), pid=>int($pid), "pop"=>int($pop), name=>$a[1], siege=>$siege, building=>\@d, ship=>\@ships, @extra});
	} 
}
$d->{planet}=\@planets;
$d->{movingfleet}=\@movingfleet;

# trades
if(m{<tr bgcolor=#303030><td colspan=2>(.+?)<br></td></tr>}) {
	my @a=split("<br>",$1);
	foreach my $a (@a) {
		if($a=~m{\?id=(\d+)>([^<]+)</a>}) {
			$a={pid=>int($1), name=>$2};
		}
	}
	$d->{trade}=\@a;
}

# race
if(m{<ul type=square><li>(.*?)</li></ul></td>}) {
	my @a=split("</li><li>", $1);
	foreach my $a (@a) {
		if($a eq "Trader") { $d->{racetrader}=1 }
		if($a eq "Start Up Lab") { $d->{racesul}=1 }
		if($a=~m{^([-+]\d+)% (\w+) \(([-+]\d+)\)$}) {
			$a=[$2, int($1), int($3)];
			$d->{"race$2"}={percent=>int($1), n=>int($3)};
		}
	}
#	$d->{race}=\@a;
}

# sciences and other bottom info
foreach my $line (m{<tr><td bgcolor=#303030>(.+?)</td></tr>}g) {
	my @a=split(/<\/td><td[^>]*>/,$line);
	my @extra=();
	my $x=lc($a[0]);
	if($a[0] eq "Trade Revenue") {chop($a[1])}
	elsif($a[0] eq "Planets" && $a[1]=~m/^ (\d+) of (\d+)$/) {
		$a[1]=$1;
		$d->{culture}=$2;
	}
	if($x=~m/=/) { $x='pointcomposition'; $a[0]=~s/ =$//;my @b=map{int($_)} split(' \+ ',$a[0]); 
		@extra=("pop"=>$b[0], pl=>$b[1], sci=>$b[2]);
	}
	else { $x=~s/[^a-z0-9]//g; }
	$a[1]=~s/^\+(\d+)\/h$/$1/; # for hourly productions
	$a[1]=toint($a[1]);
	
	$d->{$x}={title=>$a[0], value=>$a[1], @extra};
}

if(m{<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" bgcolor='#000000' width="600"><tr><td><center>([^<\n]*)<br>}) {
	$d->{name}=$1;
}

2;
