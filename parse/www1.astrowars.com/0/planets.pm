use strict;
use awparser;

$d->{"spend_all_points"}=tobool(m{<td><a href="/0/Planets/Spend_All_Points.php"><b>Spend All Points</b></a></td>});


my @p;
foreach my $pline (m{<tr align=center bgcolor="#404040"(.+?)</tr>}g) {
	if(my @a=($pline=~m{\?i=(\d+)>([^<]+)</a></td><td>(\d+)</td><td> <img src="/images/dot.gif" height="10" width="(\d+)"><img src="/images/leer.gif" height="10" width="(\d+)"></td><td>\+(\d+)</td><td>(\d+)</td><td>\+(\d+)</td>})) {
		for my $n(0,2..7) {$a[$n]+=0;}
		push(@p, \@a);
	}
}
$d->{planets}=\@p;

if(my @a=m{<td colspan=4>Growth ([+-]\d+)%.*Production ([+-]\d+)%</td>}) {
	foreach my $a (@a) {$a+=0}
	$d->{growthbonus}=$a[0];
	$d->{productionbonus}=$a[1];
}

2;
