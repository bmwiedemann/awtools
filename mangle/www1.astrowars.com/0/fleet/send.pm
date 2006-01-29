use strict;
use CGI;
use awstandard;

my $align=' align="right" style="padding:0px; color:#4978ff"';
my $delim=": &nbsp;";

sub addtimer($$$) { my($n,$time,$script)=@_;
#   my($sec,$min,$hour,$mday,$mon,$year)=gmtime($time);
#   $mon++;$year+=1900;
   $script=~s% //inserthere%$&\n reftime[$n] = $time; c$n=window.setInterval("C($n)",100);%;
   $_[2]=$script;
}

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
   my $altime;

# calc timezone
   my $extrainfo="";
   my $tz;
   if(m/<title>(.*)/) {
      $tz=awstandard::guesstimezone($1);
      my $tzh=sprintf("%i",$tz/3600);
      if($tz>=0) {$tzh="+$tzh"}
      $extrainfo.="<tr><td$align>Timezone$delim</td><td> UTC$tzh </td></tr>";
   }
   my $extrainfo2="";
   if(m/Calculated arrival time: ([^<]*)/) {
      $altime=parseawdate($1);
      my $suf="L";
      my $flighttime="";
      if(defined $tz) { # convert to UTC
         $altime-=$tz;
         $suf="UTC";
         my $t=$altime-$time;
         $flighttime=sprintf("<tr><td$align>Flight time$delim</td><td> %is = %.2fh = %i:%.2i:%.2i</td></tr>", $t, $t/3600, $t/3600, $t/60%60, $t%60);
      }
      $extrainfo2.="<tr><td$align>Arrival time$delim</td><td> <!--inserthere-->".AWisodatetime($altime)." $suf </td></tr>$flighttime";
   }

   my $script="";

# auto-update arrival time
if(1) {
   use Time::HiRes;
   my $starttime=sprintf("%i.%.6i ;", Time::HiRes::gettimeofday()); 
   $script=qq^
<script type="text/javascript">
<!--
   starttime = $starttime
   var startdiff = (startd.getTime()/1000) - starttime;
   //inserthere

      //-->
   </script>
      ^;
   my $commonattr=qq'type="text" size="28" class="text" style="text-align:left; background-color: #000;"';
   if($altime) {
      addtimer(1, $altime, $script);
      $extrainfo2=~s%<!--inserthere-->([^<]*)%<form><input name="z" $commonattr value="$altime">$1</form>%;
   }
   addtimer(0, $time, $script);
   $time=AWisodatetime($time);
   $time=qq'<form><input name="z" $commonattr value="$time"> $time UTC</form>';
   s%</head>%<script type="text/javascript" src="http://aw.lsmod.de/code/js/fleet_send.js"></script>$&%;
} else {
   $time=AWisodatetime($time);
}


# add echo of destination
   my $destsid=$cgi->param("destination");
   my $destpid=$cgi->param("planet");
   my $srcsid=$cgi->param("nr");
   my $srcpid=$cgi->param("id");
   my $destname=display_sid2($destsid);
   my $srcname=display_sid2($srcsid);
   
# add awauth
   for my $l ($destname, $srcname) {
      $l=~s%<a href="http://aw.lsmod.de/cgi-bin%$::bmwlink%;
   }

# add everything only here to the output HTML:
   s%(<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" bgcolor='#000000' width="600"><tr><td><br>\n)(<b>)%$1 <table><tr><td$align>Fleet$delim</td><td> $fleet</td></tr><tr><td$align>From$delim</td><td> $srcsid#$srcpid = $srcname $srcpid</td></tr><tr><td$align>To$delim</td><td> $destsid#$destpid = $destname $destpid</td></tr>${extrainfo}<tr><td$align>Launch time$delim</td><td> $time</td></tr>$extrainfo2</table>$script<br> $2%;
#   s%<b>Calculated%<table><tr><td$align>Fleet$delim</td><td> $fleet</td></tr><tr><td$align>From$delim</td><td> $srcsid#$srcpid = $srcname $srcpid</td></tr><tr><td$align>To$delim</td><td> $destsid#$destpid = $destname $destpid</td></tr>${extrainfo}<tr><td$align>Launch time$delim</td><td> $time UTC</td></tr>$extrainfo2</table>$&%;

# add submit to send
   my $form="<form method=\"post\">";
   foreach my $p ($cgi->param) {
      next if $p eq "calc";
      $form.="\n<input type=\"hidden\" name=\"$p\" value=\"".($cgi->param($p)).'">';
   }
   $form.="<label for=\"launch\"> Or click <input type=\"submit\" id=\"launch\" value=\"Launch !!!\" class=smbutton></label></form>";
   s%</small>% $& $form%;
#   $_.="post-data: ".$::options{post};
}

1;
