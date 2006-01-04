use strict;
use CGI;

{
   my $cgi=new CGI($::options{post});
# add echo of fleet
   my @fleet;
   for my $ship (qw(inf col des cru bat)) {
      my $n=$cgi->param($ship);
      my $s=$ship;
      $s=~s/inf/trn/;
      push(@fleet, "$n $s");
   }
   my $fleet=join(", ",@fleet);
# add echo of destination
   my $destsid=$cgi->param("destination");
   my $destpid=$cgi->param("planet");
   my $destname=systemid2name($destsid)||"";
# add current time - but no timezone known so only GMT
   my $time=AWisodatetime(time());
   
   s/<b>Calculated/Fleet: $fleet<br>Target: $destsid#$destpid = $destname #$destpid<br>Launch time: $time GMT<br>$&/;
#   $_.="post: ".$::options{post};
}

1;
