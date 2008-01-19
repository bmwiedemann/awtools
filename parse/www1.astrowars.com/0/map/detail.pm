use strict;
use awparser;

my($sysname, $sysx, $sysy)=(m{<tr align=center><td colspan="5">Planets at <b>([^<]+)</b> \(([-0-9]+)/([-0-9]+)\)</b></td></tr>});
$d->{name}=$sysname;
$d->{x}=int($sysx);
$d->{y}=int($sysy);

my @planet=();
foreach my $line (m{<tr bgcolor=("#\d+" align=center><td>.+?)</tr>}g) {
   if($line=~m{#(\d+)" align=center><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(?:<a href=/0/Player/Profile.php/\?id=(\d+)>)?([^<]+)}) {
      push(@planet, {id=>int($2), sieged=>tobool($1 ne "404040"), "population"=>int($3), starbase=>int($4), pid=>int($5), name=>$6});
   }
}
$d->{planet}=\@planet;

2;
