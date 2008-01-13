use strict;
use awparser;

my @planets=();
foreach my $line (m{<tr align=center bgcolor=(.+?)</tr>}g) {
	if(my @a=($line=~m{^#(\d+)><td(?: title="([^"]*)")?>})) {
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
		my @extra=();
		if($d[3] eq "N/A") { push(@extra, foreignplanet=>1) }
		push(@planets, {name=>$a[1], siege=>$siege, data=>\@d, @extra});
	}
}
$d->{planets}=\@planets;

# trades
if(m{<tr bgcolor=#303030><td colspan=2>(.+?)<br></td></tr>}) {
	my @a=split("<br>",$1);
	foreach my $a (@a) {
		if($a=~m{\?id=(\d+)>([^<]+)</a>}) {
			$a=[int($1),$2];
		}
	}
	$d->{trades}=\@a;
}

# race
if(m{<ul type=square><li>(.*?)</li></ul></td>}) {
	my @a=split("</li><li>", $1);
	foreach my $a (@a) {
		if($a=~m{^([-+]\d+)% (\w+) \(([-+]\d+)\)$}) {
			$a=[$2, int($1), int($3)];
			$d->{"race$2"}=[int($1), int($3)];
		}
	}
	$d->{race}=\@a;
}

# sciences and other bottom info
foreach my $line (m{<tr><td bgcolor=#303030>(.+?)</td></tr>}g) {
	my @a=split(/<\/td><td[^>]*>/,$line);
	my $x=lc($a[0]);
	if($a[0] eq "Trade Revenue") {chop($a[1])}
	elsif($a[0] eq "Planets" && $a[1]=~m/^ (\d+) of (\d+)$/) {
		(@a[1,2])=($1,$2);
		$d->{culture}=$2;
	}
	if($x=~m/=/) { $x='pointcomposition'; $a[0]=~s/ =$//;$a[0]=[map{int($_)} split(' \+ ',$a[0])]; }
	else { $x=~s/[^a-z0-9]//g; }
	$a[1]=~s/^\+(\d+)\/h$/$1/;
	$a[1]=toint($a[1]);
	
	$d->{$x}=\@a;
}

if(m{<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" bgcolor='#000000' width="600"><tr><td><center>([^<\n]*)<br>}) {
	$d->{name}=$1;
}

2;
