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
#      if($key eq "Playerlevel") {}
      if($key eq "Plays from") {
         ($value)=($value=~m-/images/flags/(\w{1,4})\.png-);
         $d->{country}=$value||"";
      }
      elsif($key eq "Origin") {
         $value=~m{(-?\d+)/(-?\d+)};
         $d->{origin}=[int($1),int($2)];
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
            $d->{multi}=[$colour, $status{$colour}];
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
         my $k=lc($key);
         $k=~s/[^a-z]//g;
         if($k) {
            $d->{$k}=toint($value);
         }
      }
      push(@data, [$key, toint($value)]);
   } elsif ($line=~m{Race/Detail.php/\?id=([^"]*)}) {
      my @race=split(",",$1);
      foreach my $a (@race) {$a+=0}
      # TODO percentages?
      $d->{race}=\@race;
   } elsif ($line=~m{>\s*([^<]+)( \(\d+[^)<]*\)</font>)?(<br><small>Premium Member</small>)?</b></center>}) {
      $d->{name}=$1;
      $d->{premium}=tobool($3);
      if($2=~m/^ \((\d+)/) {
         $d->{permarank}=int($1);
      } else { $d->{permarank}=0 }
      if($line=~m{<font color="#AAAAAA">\[(\w+)\]</font>}) {
         $d->{tag}=$1;
      }
   } else {
#      $d->{$n++}=$line;
   }
}
$d->{data}=\@data;

2;
