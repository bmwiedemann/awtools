package mangle::player_profile;
use strict;
use awstandard;
use awinput;
use awhtmlout;

# add AWTools link at bottom
if(m%(<b>Player / Profile</b></td>\s*<td>)([^<]*)%) {
   $::extralink="$::bmwlink/relations?name=$2\">AWTools($2)</a>";
}
s%(<b>Player / Profile</b></td>\s*<td>)([^<]*)%$1$::bmwlink/relations?name=$2">AWTools($2)</a>%;

my $name=$2;
# test for available intel
my $pid=playername2idm($name);
my ($rac,$sci)=awinput::playerid2ir($pid);
my ($racestr,$scistr)=ir2string($rac,$sci);

if($rac && defined($rac->[0])) {
   my($science,$intel)=("-","?");
   if(defined($$sci[0]) && $$sci[0]>100) {
      $intel=int((time()-$$sci[0])/3600/24)."d";
      $science=$scistr;
   }
   $$rac[7]="..".(-$$rac[7]);
   my $race=$racestr;
   my $etc=playerid2etc($pid);
   if($etc) {$etc=AWisodatetime($etc);$etc="<tr><td bgcolor=\"#303030\">ETC</td><td>$etc</td></tr>";}
   if(!m/Intelligence Report/) {
      s%</table></td></tr></table>%$&<br> \n</td><td><table border="0" cellspacing="1" bgcolor="#404040"><tr><td>\n<table border="0" cellpadding="2" bgcolor="#101010">\n<tr><td colspan="2" bgcolor="#202060"><b>Tools Intelligence Report</b></td></tr><tr><td bgcolor="#303030">age</td><td>$intel</td></tr><tr><td bgcolor="#303030">race</td><td>$race</td></tr><tr><td bgcolor="#303030">science</td><td>$science</td></tr></table></td></tr></table><br>%;
   }
   if($etc){s%<tr><td bgcolor="#303030">Culturelevel</td><td>\d+</td></tr>%$& $etc%;}
}

# add idle time (even for premium members)
use awlogins;
my $logins=awlogins::get_logins($ENV{REMOTE_USER},$pid, "ORDER BY `time` DESC LIMIT 1");
if($logins && defined($logins->[0])) {
	my @l=@{$logins->[0]};
	my $idle=sprintf("%im", (time()-$l[1])/60);
	s!(>Idle</td><td>[^<]*)!$1 = $idle!;
}

use awsql;
my $prem=m!<small>Premium Member</small>! || 0;
update_premium($pid, $prem);

1;
