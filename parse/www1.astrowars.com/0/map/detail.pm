use strict;
use awparser;

my($sysname, $sysx, $sysy)=(m{<tr align=center><td colspan="5">Planets at <b>([^<]+)</b> \(([-0-9]+)/([-0-9]+)\)</b></td></tr>});
$d->{name}=$sysname;
$d->{x}=int($sysx);
$d->{y}=int($sysy);

my @planet=();
foreach my $line (m{<tr bgcolor=("#\d+" align=center><td>.+?)</tr>}g) {
   if($line=~m{#(\d+)" align=center><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td><a href=/0/Player/Profile.php/\?id=(\d+)>([^<]+)</a>}) {
      push(@planet, [int($2),tobool($1 ne "404040"),int($3),int($4),int($5),$6]);
   }
}
$d->{planets}=\@planet;

2;
