use strict;
use awparser;

if(m{Points: (\d+)</td>\n<td>\|</td><td>Rank: #(\d+)</td>}) {
   $d->{points}=int($1);
   $d->{rank}=int($2);
}

if($::options{url}=~m{Planets/$}) {
$d->{"spend_all_points"}=tobool(m{<td><a href="/0/Planets/Spend_All_Points.php"><b>Spend All Points</b></a></td>});

my @p;
foreach my $pline (m{<tr align=center bgcolor="#404040"(.+?)</tr>}g) {
	if(my @a=($pline=~m{\?i=(\d+)>([^<]+)</a></td><td>(\d+)</td><td> <img src="/images/dot.gif" height="10" width="(\d+)"><img src="/images/leer.gif" height="10" width="(\d+)"></td><td>\+(\d+)</td><td>(\d+)</td><td>\+(\d+)</td>})) {
		for my $n(0,2..7) {$a[$n]+=0;}
      my @b=splice(@a,3,2);
      $a[2]+=$b[0]/100; # or /($b[0]+$b[1])
		my @label=qw(id name population growth pp production);
		my %a=();
		for my $n(0..5) {$a{$label[$n]}=$a[$n]}
		push(@p, \%a);
	}
}
$d->{planet}=\@p;

if(my @a=m{<td colspan=4>Growth ([+-]\d+)%.*Production ([+-]\d+)%</td>}) {
	foreach my $a (@a) {$a+=0}
	$d->{growthbonus}=$a[0];
	$d->{productionbonus}=$a[1];
}
}

2;
