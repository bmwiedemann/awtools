# add AWTools link at bottom
s%(<b>Player / Profile</b></td>\s*<td>)([^<]*)%$1$::bmwlink/relations?name=$2">AWTools($2)</a>%;

my $name=$2;
# test for available intel
my @rel=getrelation($name);
if($rel[0]) {
   my @science=relation2science($rel[2]);
   my @race=relation2race($rel[2]);
   if(defined($science[0]) && $science[0]>100) {
      my $intel=int((time()-$science[0])/3600/24)."d";
      my $race=join(",",@race);
      my $science=join(",",@science[1..6]);
      my $etc=$science[8];
      if($etc) {$etc="<tr><td bgcolor=\"#303030\">ETC</td><td>".AWisodatetime($etc)."</td></tr>";}
      if(!m/Intelligence Report/) {
         s%</table></td></tr></table>%$& \n</td><td><table border="0" cellspacing="1" bgcolor="#404040"><tr><td>\n<table border="0" cellpadding="2" bgcolor="#101010">\n<tr><td colspan="2" bgcolor="#202060"><b>Tools Intelligence Report</b></td></tr><tr><td bgcolor="#303030">age</td><td>$intel</td></tr><tr><td bgcolor="#303030">race</td><td>$race</td></tr><tr><td bgcolor="#303030">science</td><td>$science</td></tr></table></td></tr></table>%;
      }
      if($etc){s%<tr><td bgcolor="#303030">Culturelevel</td><td>\d+</td></tr>%$& $etc%;}
   }
}

1;
