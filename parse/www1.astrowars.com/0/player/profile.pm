use strict;
use awparser;

my $n=0;
my @data=();
foreach my $line (m{<tr><td(.+?)</tr>}gs) {
   if(my($key,$value)=($line=~m{bgcolor="#303030">(.*?)</td><td.(.*?)</td>$}s)) {
#      $d->{$1}=$2;
      for my $x ($key,$value) { # strip links from both key and value
         $x=~s{.*>([^>]+)</a>}{$1}s;
      }
      $value=~s/\n//g;
      if($key eq "Plays from") {
         ($value)=($value=~m-/images/flags/(\w{1,4})\.png-);
			$value||="";
      }
		elsif($key eq "Trade Revenue") {
			$value=~s/%$//;
		}
      elsif($key eq "Playerlevel") { 
			$value=~s/(\d+) - (\d+)%/$1+$2\/100/e;
		}
      elsif($key eq "Origin") {
         $value=~m{(-?\d+)/(-?\d+)};
         $value={x=>int($1), y=>int($2)};
      }
      elsif($key eq "Rank (Points Scored)") {
         $value=~m{#(\d+) \((\d+)\)};
         $d->{rank}=int($1);
         $d->{points}=int($2);
      }
      elsif($key eq "Multi") {
         if($value=~m{bgcolor='#(\d+)'>Status}) {
            my $colour=$1;
            my %status=("206020"=>0, "606020"=>1, "602020"=>2);
            $value={color=>$colour, status=>$status{$colour}};
         }
      }
      elsif($key eq "Idle") {
         my %timevalue=(""=>1, second=>1, minute=>60, hour=>3600, day=>86400);
         my $idle;
         my $idleunit;
         if($value eq " N/A") {
            $idle=0;
            $idleunit=-1;
         } else {
            my($n,$timestr)=($value=~m/(\d+) (.*)/);
            $timestr=~s/s$//;
            $idleunit=$timevalue{$timestr};
            $idle=$n*$idleunit;
         }
         $d->{idletime}=$idle;
         $d->{idleunit}=$idleunit;
      }
      else {
      }
		$value=tofloat($value);
      push(@data, [$key, $value]);
		my $k=lc($key);
		if($k) {
			$k=~s/[^a-z]//g;
			$d->{$k}=$value;
		}
   } elsif ($line=~m{Race/Detail.php/\?id=([^"]*)}) {
      my @race=split(",",$1);
      foreach my $a (@race) {$a+=0}
      # TODO percentages?
		my %race=(flags=>$race[0]);
		foreach my $n (1..7) {
			$race{$awstandard::racestr[$n-1]}=$race[$n];
		}
      $d->{racevalue}=\@race;
		$d->{race}=\%race;
   } elsif ($line=~m{>\s*([^<]+)( \(\d+[^)<]*\)</font>)?(<br><small>Premium Member</small>)?</b></center>}) {
      $d->{name}=$1;
      $d->{premium}=tobool($3);
      if($2=~m/^ \((\d+)/) {
         $d->{permarank}=int($1);
      } else { $d->{permarank}=0 }
      if($line=~m{<font color="#AAAAAA">\[(\w+)\]</font>}) {
         $d->{tag}=$1;
      }
   } elsif ($line=~m{forums/privmsg\.php\?mode=post&u=(\d+) target="_blank}) {
      $d->{pid}=$1;
   } else {
#      $d->{$n++}=$line;
   }
}
$d->{data}=\@data;

2;
