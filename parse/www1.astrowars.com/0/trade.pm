use strict;
use awparser;

if($::options{url}=~m/Trade\/(?:\?debug.*)?$/) {

   my @p=();
   my @arti=();
   foreach my $line (m{<tr bgcolor=(.+?)</tr>}g) {
      # fetch prices:
      if(my ($code,$name,$value)=($line=~m{<a href=Stats/([0-9a-z-]+)\.html>([^<]+)</a></td><td align=right>\$([0-9.,-]+)})) {
#         $d->{$code}=[$code,$name,$value];
         push(@p, [$code,$name,unprettyprint($value)]);
      } elsif($line=~m{#(\d+)'><td>&nbsp;([a-zA-Z ]+ \d)</td><td align=center>(\d+)</td>}) {
         my $current=0;
         if($1 ne "404040") {
            $d->{currentartifact}=$2;
            $current=1;
         }
         push(@arti, [$2, int($3), $current]);
      } elsif($line=~m{id=33>Supply Units</a></td><td align=center>(\d+)/(\d+)}) {
         $d->{su}=[int($1),int($2)];
      } elsif($line=~m{id=48>Astro Dollars</a></td><td align=center>\$([-+0-9.,]+)</b>}) {
         $d->{ad}=unprettyprint($1);
      } else {
         $d->{debug}=$line;
      }
   }
   $d->{prices}=\@p;
   $d->{artifacts}=\@arti;

   if(m{<tr align=center bgcolor='#303030'><td>Trade Revenue</td><td>([+-]?\d+)%</td></tr>}) {
      $d->{traderevenue}=int($1);
   }
}

2;
