use strict;
use awparser;
use awstandard;

# fleets and planets
my @planets=();
my @movingfleet=();
foreach my $line (m{<tr(.+?)</t[dh]>\s*</tr>}gs) {
	if(my @a=($line=~m{^(?: class="(\w+)")?>\s*<td(?: title="([^"]*)")?>})) {
		my @extra=();
		my @d=split(/<\/td>\s*<td[^>]*>/,$');
		my $sid=shift(@d);
		$sid=~s{.*\?nr=(\d+)".*}{$1};
		next if $sid eq "SID";
		my $pid=shift(@d);
		# moving
		if($a[0] eq "flying") {
			my $eta=parseawdate(shift(@d));
			my @ships=map {int($_)} @d;
			my $cv=pop(@ships);
			foreach my $n (0..4) { push(@extra, lc($awstandard::shipstr[$n]), $ships[$n])}
			push(@movingfleet, {sid=>$sid, pid=>$pid, eta=>$eta, ship=>\@ships, cv=>$cv, @extra});
			next;
		}
		#$d->{debug}="@d ---".$line;
		my $siege;
		if($a[0] eq "") {
			$siege=0;
		} elsif($a[0] eq "sieged") {
			$siege=1;
		} else {
			next;
		}
		my $pop=shift(@d);
		my $pp=shift(@d);
		my @ships=splice(@d, 5, 5);
		if($d[3] eq "N/A") { push(@extra, foreignplanet=>1); splice(@d,0,5); }
		foreach my $a (@ships) {$a+=0}
		foreach my $a (@d) {$a+=0}
		if(defined($d[0])) {
			foreach my $n (0..4) { push(@extra, lc($awstandard::buildingstr[$n]), $d[$n])}
		}
		foreach my $n (0..4) { push(@extra, lc($awstandard::shipstr[$n]), $ships[$n])}
		
		push(@planets, {sid=>int($sid), pid=>int($pid), "pop"=>$pop, "pp"=>$pp, name=>$a[1], siege=>$siege, building=>\@d, ship=>\@ships, @extra});
	} elsif($line=~m{>\s*<td class="incoming">}) {
		require parse::libincoming;
		my $inco=parse::libincoming::parse_incoming($line);
		#$inco->{eta}-=$d->{timezone};
		push(@{$d->{incoming}}, $inco);
	} elsif($line=~m/<abbr title=/) { # headings
	} elsif($line=~m{>\s*<th scope="row">(.+)}s) {
		# sciences and other bottom info
		my @a=split(/<\/th>\s*<td[^>]*>/,$1);
		my @extra=();
		my $x=lc($a[0]);
		$a[1]=~s{/<span.*}{};#chop effective value from sci/cul/prod
		if($a[0] eq "Trade Revenue") {chop($a[1])}
		elsif($a[0] eq "Planets" && $a[1]=~m/^(\d+) of (\d+)$/) {
			$a[1]=$1;
			$d->{culturelevel}=$2;
		}
		if($x=~m/=/) { $x='pointcomposition'; $a[0]=~s/ =$//;my @b=map{int($_)} split(' \+ ',$a[0]); 
			@extra=("pop"=>$b[0], pl=>$b[1], sci=>$b[2]);
		}
		else { $x=~s/[^a-z0-9]//g; }
		$a[1]=~s/^\+(\d+)\/h$/$1/; # for hourly productions
		$a[1]=toint($a[1]);
		
		$d->{$x}={title=>$a[0], value=>$a[1], @extra};
		# sciences/bottominfo end
	} else {
		$d->{debug2}=$line;
	}
}
for my $x ("production", "science", "culture") {
  	# crop to base value ; omit value with bonus
	$d->{$x}->{value} =~ s!^\+(\d+) .*!$1!;
}
$d->{planet}=\@planets;
$d->{movingfleet}=\@movingfleet;


# trades
if(m{<h2>Trade Partners</h2>\s*<ul[^>]*>(.*?)</ul>\s*</div>}s) {
	my @a=split(/<\/li>\s*<li>/,$1);
	my @a2=();
	foreach my $a (@a) {
		if($a=~m{\?id=(\d+)">([^<]+)</a>}) {
			$a={pid=>int($1), name=>$2};
			push(@a2,$a);
		}
	}
	$d->{tradeagreement}=\@a2;
}

# race
if(m{<ul class="race"><li>(.*?)</li></ul>}) {
	my @a=split("</li><li>", $1);
	foreach my $a (@a) {
		if($a eq "Trader") { $d->{racetrader}=1 }
		elsif($a eq "Start Up Lab") { $d->{racesul}=1 }
		elsif($a=~m{^([-+]\d+)[%h] (\w+) \(([-+]\d+)\)$}) {
			$a=[$2, int($1), int($3)];
			$d->{"race$2"}={percent=>int($1), n=>int($3)};
		} else {
			$d->{debugrace}=$a;
		}
	}
}

$d->{name}=getcaption($_);
$d->{name}=~s{.*\?id=(\d+)">([^<]+)</a>.*}{$2};
$d->{pid}=$1;

2;
