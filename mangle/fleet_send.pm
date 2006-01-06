use strict;
use CGI;
use awstandard;

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
   
# add current time (UTC/GMT)
   my $time=time();

# calc timezone
   my $extrainfo="";
   my $tz;
   if(m/<title>(.*)/) {
      $tz=awstandard::guesstimezone($1);
      $extrainfo.="Your timezone: UTC+$tz s<br>";
   }
   my $extrainfo2="";
   if(m/Calculated arrival time: ([^<]*)/) {
      my $altime=parseawdate($1);
      my $suf="L";
      my $flighttime="";
      if(defined $tz) { # convert to UTC
         $altime-=$tz;
         $suf="UTC";
         my $t=$altime-$time;
         $flighttime=sprintf("Flight time: %is = %.2fh = %i:%.2i:%.2i<br>", $t, $t/3600, $t/3600, $t/60%60, $t%60);
      }
      $extrainfo2.="Arrival time: ".AWisodatetime($altime)." $suf <br>$flighttime";
   }
# add echo of destination
   my $destsid=$cgi->param("destination");
   my $destpid=$cgi->param("planet");
   my $srcsid=$cgi->param("nr");
   my $srcpid=$cgi->param("id");
   my $destname=systemid2name($destsid)||"";
   my $srcname=systemid2name($srcsid)||"";
   $time=AWisodatetime($time);
   
   s/<b>Calculated/Fleet: $fleet<br>From: $srcsid#$srcpid = $srcname #$srcpid<br>To: $destsid#$destpid = $destname #$destpid<br>${extrainfo}Launch time: $time UTC<br>$extrainfo2$&/;

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
