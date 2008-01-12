use strict;
use awparser;

my @p;
foreach my $pline (m{<tr align=center bgcolor="#404040"(.+?)</tr>}g) {
   if(my @a=($pline=~m!\?i=(\d+)>([^<]+)</a></td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td>!)) {
      for my $n(0,2..7) {$a[$n]+=0;}
      push(@p,\@a);
   }
}
$d->{planets}=\@p;

2;
