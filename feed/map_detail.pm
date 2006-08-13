use strict;
use MLDBM qw(DB_File Storable);
use Fcntl;
our %planets; # imported from awinput

my $debug=$::options{debug};
if($debug) {print "debug mode - no modifications done<br>\n"}

sub filter() {
   return if(!m!Planets at <b>([^<]*)</b> \((-?\d+)/(-?\d+)\)! || !$::options{url});
   return if($ENV{REMOTE_USER} eq "xr"); # TODO : drop later?
   my ($sysname,$x,$y)=($1,$2,$3);
   my $sid=systemcoord2id($x,$y); #systemname2id($sysname);
   if ($::options{url}=~m/\?nr=(\d+)/) {$sid=$1}
   my $system=$planets{$sid};
   return if ! $system;
   my @system=@$system;
   print qq!update on <a href="system-info?id=$sid">$sysname</a> ($x,$y)<br>\n!;
   m/Population.*?Starbase.*?Owner(.*)/s;
   $_=$1;

   untie %planets;
   tie %planets, "MLDBM", "db/planets.mldbm", O_RDWR|O_CREAT, 0666 or print "can not write DB: $!";

   my @a;
   for(;(@a=m!<tr bgcolor=".(\d{6})"[^>]*><td[^>]*>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(<a href=[^>]+>|)([^<]+)(?:</a>)?</td></tr>(.*)!); $_=$a[6]) {
      my ($bgcolor,$pid,$pop,$sb,$link,$owner)=@a;
      my $siege=($bgcolor eq "602020")?1:0;
      if($pop==0) {$pop++}
      my $details="$pid $pop $sb $siege $owner";
      my $playerid;
      if($link=~/id=(\d+)/) {$details.="($1)"; $playerid=$1}
      my $p=$system[$pid-1]; #getplanet($sid,$pid);
      next if(!$p);
      $details.=" old: ".planet2pop($p)." ".planet2sb($p)." ".planet2siege($p);
      $$p{s}=$siege;
      print "$details<br>\n";
      next if not $playerid;
      $$p{ownerid}=$playerid;
      $$p{pop}=$pop;
      $$p{sb}=$sb;
   }
   if(!$debug) {
      $planets{$sid}=\@system;
   }
   untie %planets; # flush write buffers and avoid unwanted later modifications
}

filter();

1;
