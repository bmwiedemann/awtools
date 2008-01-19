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
         $d->{test}++;
         @a=($line=~m{><td>([^<]+)</td><td>(?:<a href=/0/Map/.?.hl=(?:\d+)>)?<small>([^<]*)\s(\d+)</small>(?:</a>)?</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)});
         $target=\@movingfleet;
         $fleetinfo{eta}=parseawdate(shift(@a));
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
# TODO pending
# TODO add marker when >20 fleet warning appears
}

2;
