use strict;
use awparser;

if(m{Points: (\d+)</td>\n<td>\|</td><td>Rank: #(\d+)</td>}) {
   $d->{points}=int($1);
   $d->{rank}=int($2);
}

if($::options{url}=~m{Planets/$}) {
$d->{"spend_all_points"}=tobool(m{<td><a href="/0/Planets/Spend_All_Points.php"><b>Spend All Points</b></a></td>});

my @p;
foreach my $pline (m{<tr align=center bgcolor=(.+?)</tr>}g) {
	if(my @a=($pline=~m{\?i=(\d+)>([^<]+)</a></td><td>(\d+)</td><td> <img src="/images/dot.gif" height="10" width="(\d+)"><img src="/images/leer.gif" height="10" width="(\d+)"></td><td>\+(\d+)</td><td>(\d+)</td><td>\+(\d+)</td>})) {
		for my $n(0,2..7) {$a[$n]+=0;}
      my @b=splice(@a,3,2);
      $a[2]+=$b[0]/100; # or /($b[0]+$b[1])
		my @label=qw(id name population growth pp production);
		my %a=();
		for my $n(0..5) {$a{$label[$n]}=$a[$n]}
		#require awinput;
		#awinput::awinput_init(1);
		my $name=$a{name};
		$name=~s/\s(\d+)$//;
		$a{pid}=$1;
		$a{sid}=awinput::systemname2id($name);
		#awinput::awinput_finish();
		push(@p, \%a);
	}
	elsif (@a=($pline=~m{^'#303030'><td colspan=4>Growth ([+-]\d+)%.*Production ([+-]\d+)%</td><td>(-?\d+)</td><td>([+-]\d+)</td>$})) {
		foreach my $a (@a) {$a+=0}
		$d->{growthbonus}=shift(@a);
		$d->{productionbonus}=shift(@a);
		$d->{totalpp}=shift(@a);
		$d->{hourlypp}=shift(@a);
	}
}
$d->{planet}=\@p;

}

2;
