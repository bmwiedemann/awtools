use strict;
use awparser;

my @p;
foreach my $pline (m{<tr align=center bgcolor="#404040"(.+?)</tr>}g) {
   if(my @a=($pline=~m!\?i=(\d+)>([^<]+)</a></td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td>!)) {
      for my $n(0,2..7) {$a[$n]+=0;}
		my @label=qw(id name population farm factory cybernet lab pp);
		my %a=();
		for my $n(0..7) {$a{$label[$n]}=$a[$n]}
      push(@p, \%a);
   }
}
$d->{planet}=\@p;

2;
