use strict;
use awparser;

my @p;
foreach my $pline (m{<tr align=center bgcolor="#(\d+".+?)</tr>}g) {
   if(my @a=($pline=~m!^(\d+).*\?i=(\d+)>([^<]+)</a></td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td>!)) {
		my %a=(siege=>((shift(@a) eq "602020")?1:0));
      for my $n(0,2..7) {$a[$n]+=0;}
		my @label=qw(id name population farm factory cybernet lab pp);
		for my $n(0..7) {$a{$label[$n]}=$a[$n]}
      push(@p, \%a);
   }
}
$d->{planet}=\@p;

2;
