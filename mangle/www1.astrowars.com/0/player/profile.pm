package mangle::player_profile;
use strict;
use awstandard;
use awinput;
use awhtmlout;
use DBAccess2;

# add AWTools link at bottom
if(m%(<li class="bold">Player / Profile</li>\s*<li>)([^<]*)% && !$::options{handheld}) {
   $::extralink="$::bmwlink/relations?name=$2\">AWTools($2)</a>";
}
s%(<li class="bold">Player / Profile</li>\s*<li>)([^<]*)%$1$::bmwlink/relations?name=$2">AWTools($2)</a>%;

my $name=$2;
# test for available intel
my $pid=playername2idm($name);
my ($rac,$sci)=awinput::playerid2ir($pid);
my ($racestr,$scistr)=ir2string($rac,$sci);

my $etc="";
if($rac && defined($rac->[0])) {
   my($science,$intel)=("-","?");
   if(defined($$sci[0]) && $$sci[0]>100) {
      $intel=int((time()-$$sci[0])/3600/24)."d";
      $science=$scistr;
   }
   $$rac[7]="..".(-$$rac[7]);
   my $race=$racestr;
   $etc=playerid2etc($pid)||"";
   if($etc) {$etc=AWisodatetime($etc);$etc="<tr><th>ETC</th><td>$etc</td></tr>";}
   if(!m/Intelligence Report/) {
      s%<br class="fillFloat"%<div id="intel">\n<table id="IRscience">\n<caption>AWTools Intelligence Report</caption><tr><td bgcolor="#303030">age</td><td>$intel</td></tr><tr><th bgcolor="#303030">race</th><td>$race</td></tr><tr><td bgcolor="#303030">science</td><td>$science</td></tr></table></div>\n$&%;
   }
}
#my($t2)=get_one_row("SELECT `trade` FROM `tradelive` WHERE `pid`=?", [$pid]);
my $trade="";#$t2?qq(<tr><th>TradeLive</th><td>$t2%</td></tr>):"";
if($trade||$etc) {
	s%<tr>\s*<th scope="row">Culture level</th>\s*<td>\d+</td>\s*</tr>%$&$trade$etc%;
}


# add idle time (even for premium members)
use awlogins;
my $logins=awlogins::get_logins($ENV{REMOTE_USER},$pid, "ORDER BY `time` DESC LIMIT 1");
if($logins && defined($logins->[0])) {
	my @l=@{$logins->[0]};
	my $idle=sprintf("%im", (time()-$l[1])/60);
	s!(>Idle</th>\s*<td>[^<]*)!$1 = $idle!;
}

1;
