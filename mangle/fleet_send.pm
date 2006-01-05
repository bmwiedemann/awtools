use strict;
use CGI;

if($::options{post}) {
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
   my $srcsid=$cgi->param("nr");
   my $srcpid=$cgi->param("id");
   my $destname=systemid2name($destsid)||"";
   my $srcname=systemid2name($srcsid)||"";
# add current time - but no timezone known so only GMT
   my $time=AWisodatetime(time());
   
   s/<b>Calculated/Fleet: $fleet<br>From: $srcsid#$srcpid = $srcname #$srcpid<br>To: $destsid#$destpid = $destname #$destpid<br>Launch time: $time GMT<br>$&/;

# add submit to send
   my $form="<form method=\"post\">";
   foreach my $p ($cgi->param) {
      next if $p eq "calc";
      $form.="\n<input type=\"hidden\" name=\"$p\" value=\"".($cgi->param($p)).'">';
   }
   $form.="<input type=\"submit\" value=\"Launch !!!\" class=smbutton></form>";
   s%</small>% $& or click $form%;
#   $_.="post: ".$::options{post};
}

1;
