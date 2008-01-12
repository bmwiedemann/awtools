use strict;
use awparser;

my $n=0;
my @ta=();
foreach my $line (m{<tr align=center bgcolor=(.+?)</tr>}g) {
   if($line=~m{colspan="2">Preview</td><td colspan=2>([-+0-9]+)%</td>}) {
      $d->{preview}=int($1);
   } elsif($line=~m{id=(\d+)>([^<]*)</a></b></td><td>(\d+)</td><td>([^<]*)</td>}) {
      push(@ta, {pid=>int($1), name=>$2, bonus=>int($3), status=>$4});
   } else {
#      $d->{$n++}=$line;
   }
}
$d->{ta}=\@ta;
# TODO new TAs allowed?

2;
