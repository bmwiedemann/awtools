use strict;
use awparser;
use awstandard;
use awinput;

if($::options{url}=~m/Fleet\/$/) {
   my @fleet;
   my @movingfleet;
   foreach my $line (m{<tr (.+?)</tr>}g) {
      my $sieging=tobool($line!~/bgcolor="#404040/);
      my @a;
      my %fleetinfo=();
      my $target;
      if($line=~/^align=center/) {
         @a=($line=~m{>(?:[^<]*(?:<[^s])*)*?<small>([^<]*) (\d+)</small>(?:</a>)?</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td>});
         $target=\@fleet;
      } elsif($line=~/^bgcolor="404040" align=/) {
         @a=($line=~m{><td>([^<]+)</td><td>(?:<a href=/0/Map/.?.hl=(?:\d+)>)?<small>([^<]*)\s(\d+)</small>(?:</a>)?</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)});
         $target=\@movingfleet;
         $fleetinfo{eta}=parseawdate(shift(@a));
      } elsif($line=~m{^bgcolor="606000" align="center"}) {
			$target=\@movingfleet;
			$fleetinfo{pending}=1;
			$fleetinfo{eta}=0;
         @a=($line=~m{^bgcolor="606000" align="center"><td><b>pending</b></td><td>(?:<a href=/0/Map/.?.hl=(?:\d+)>)?<small>([^<]*)\s(\d+)</small>(?:</a>)?</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)});
#bgcolor="606000" align="center"><td><b>pending</b></td><td><a href=/0/Map//?hl=1652><small>Beta Tania Australis 12</small></a></td><td>0</td><td>0</td><td>1</td><td>0</td><td>0</td>
      } elsif($line=~m{^bgcolor="#202060" align="center"><td>Limit (\d+)/(\d+)</td>}) {
			$d->{movingfleets}=$1;
			$d->{maxmovingfleets}=$2;
		} elsif($line=~m{^bgcolor="#404040" align="center"><td></td><td colspan="6"><small><b>Note:</b> You cannot see more than 20 fleets at the}) {
			$d->{fleetlimit}=1;
      } elsif($line=~m{^bgcolor="#202060" align="center"}) { # ignore
      } else {
			$d->{debug}=$line;
		}
      if($target) {
         my $system=shift(@a);
         my $sid=systemname2id($system);
         for my $a(@a){$a+=0}
         my $pid=shift(@a);
			my @ships=@a;
			my @extra=();
			foreach my $n (0..4) { push(@extra, lc($awstandard::shipstr[$n]), $ships[$n])}
         push(@$target, {%fleetinfo, "system"=>$system, "sid"=>$sid, "pid"=>$pid, ship=>\@ships, @extra});
      }
   }
   $d->{movingfleet}=\@movingfleet;
   $d->{fleet}=\@fleet;
}

2;
