package mangle::player_profile;
use awstandard;
# add AWTools link at bottom
if(m%(<b>Player / Profile</b></td>\s*<td>)([^<]*)%) {
   $::extralink="$::bmwlink/relations?name=$2\">AWTools($2)</a>";
}
s%(<b>Player / Profile</b></td>\s*<td>)([^<]*)%$1$::bmwlink/relations?name=$2">AWTools($2)</a>%;

my $name=$2;
# test for available intel
my ($rac,$sci)=awinput::playername2ir($name);
if($rac) {
   if(defined($$sci[0]) && $$sci[0]>100) {
      my $intel=int((time()-$$sci[0])/3600/24)."d";
      $$rac[7]="..".(-$$rac[7]);
      my $race=join(",",@$rac);
      my $science=join(",",@$sci[1..6]);
      my $etc=$$sci[8];
      if($etc) {$etc=AWisodatetime($etc);$etc="<tr><td bgcolor=\"#303030\">ETC</td><td>$etc</td></tr>";}
      if(!m/Intelligence Report/) {
         s%</table></td></tr></table>%$&<br> \n</td><td><table border="0" cellspacing="1" bgcolor="#404040"><tr><td>\n<table border="0" cellpadding="2" bgcolor="#101010">\n<tr><td colspan="2" bgcolor="#202060"><b>Tools Intelligence Report</b></td></tr><tr><td bgcolor="#303030">age</td><td>$intel</td></tr><tr><td bgcolor="#303030">race</td><td>$race</td></tr><tr><td bgcolor="#303030">science</td><td>$science</td></tr></table></td></tr></table><br>%;
      }
      if($etc){s%<tr><td bgcolor="#303030">Culturelevel</td><td>\d+</td></tr>%$& $etc%;}
   }
}

1;
