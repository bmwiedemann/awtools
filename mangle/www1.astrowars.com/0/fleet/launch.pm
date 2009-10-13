use strict;
use awstandard;
use awinput;
use Time::HiRes;

# activate arrival calc checkbox
s/<input type="checkbox" name="calc" value="1"/$& checked/;

# energy 0 is possible - so activate it
s/<option>1<option>2/<option>0$&/;
# add values to energy so that JS works with IE8
sub substene($) {my $x=shift; $x=~s/(<option(?: selected)?)>(\d+)/$1 value="$2">$2/g; $x}
s{(<select name="energy">\n)\d+([^/]+)(</select></td></tr>)}
 {$1.substene($2).$3}e;


# convert radio list into drop-down list
my @list=();
my $page;
for($page=$_; $page=~s%<tr align=center><td bgcolor='#404040'><a href=/0/Map//\?hl=\d+>([^<]*)</a></td><td><input type="radio" name="destination" value="(\d+)"\s*(checked)?></td></tr>%% ; ) {
   push(@list,[$1,$2,$3]);
}

my $extra=qq'<select name="destination"><option value=""></option>';
foreach my $e (@list) {
   my($name,$id,$checked)=@$e;
   my $sel=$checked||"";
   $sel=~s/checked/ selected/;
   $extra.=qq%<option$sel value="$id">$name</option>%;
}
$extra.="</select>";

$page=~s%<td colspan="3">Destination</td></tr>%$&<tr align=center><td bgcolor='#404040'>$extra</td></tr>%;

$_=$page;
#$_.=$extra;

sub piddropdown($) {
   my $ret='<select name="planet"><option></option>';
   for my $i (1..12) {
      my $sel=$_[0]==$i?" selected":"";
      $ret.=qq%<option$sel value="$i">$i</option>%;
   }
   $ret.='</select>';
   return $ret;
}

s%<input type="text" name="planet" size="2" class=text value="(\d*)">%piddropdown($1)%ge;

if(0) {
s%Energy Level</a></td><td><select name="energy">%$&<option>-9999</option>%;
}

if($ENV{REMOTE_USER}) { # && $mangle::dispatch::g) {
   $::options{url}=~/nr=(\d+)/;
   my $srcsid=$1;
   my $refs;
   my $refe;
   my($race,$sci)=awinput::playername2ir($::options{name});
# this is used for sidpid->own/allied mapping
   my $pid=awinput::playername2id($::options{name});
   my $aid=playerid2alliance($pid);
   if($race) {$refs=$$race[4];}
   if($sci) {if($$sci[0]>99){shift(@$sci)};$refe=$$sci[2]}
   my @c1=systemid2coord($srcsid);
   if(defined($refs) && defined($refe) && $srcsid && (@c1)) {
      s%</head>%<script type="text/javascript" src="http://aw.lsmod.de/code/js/arrival.js"></script><script type="text/javascript" src="http://aw.lsmod.de/code/js/bmwajax.js"></script>$&%;
      
      if(m/name="destination2" size="3" class=text value="(\d+)"/) {
         push(@list, ["",$1]);
      }
      my @distlist;
      push(@list, ["",$srcsid]);
      foreach my $e (@list) {
         my $sid=$$e[1];
         my $own="";
         my @c2=systemid2coord($sid);
         for my $i (1..12) {
            my $o;
            my $p=getplanet($sid, $i);
            if($p) {
               my $ownerid=planet2owner($p);
               if($ownerid && $ownerid>2){
                  if(!$aid) {$o=($ownerid==$pid)}
                  else {
                     my $a=playerid2alliance($ownerid);
                     $o=($a==$aid);
                  }
               }
            } else {$o=-1} # missing planet marker
            $o||=0;
            $own.=",$o";
         }
         next if(!(@c2));
         my $dist=($c2[0]-$c1[0])**2 + ($c2[1]-$c1[1])**2;
         push(@distlist, "disttable[$sid]=[$dist$own];\n");
      }
      my $tz=$timezone;
      my $starttime=sprintf("%i.%.6i ;", Time::HiRes::gettimeofday());
      s%</form>%$& <form><input class="text" name="travel" size="9" disabled> <input class="text" name="arrival" size="60" disabled></form>
      <script type="text/javascript">
         <!--
         @distlist;
         browniedomain="$ENV{HTTP_HOST}";
         aid=$aid;
         sx=$c1[0];
         sy=$c1[1];
         energy=$refe;
         racebonus=$refs;
         tz=$tz;
         starttime=$starttime
         var startdiff = (startd.getTime()/1000) - starttime;
         window.setInterval("update()", 100);
      //-->
      </script>%;
   }
   s% name="destination2"%onchange="asyncfetchdist(document.forms[0].destination2.value)"$&%;
   s%</body>%<span class="bmwnotice">note: predicted arrival time will be wrong if your local clock is wrong (or target ownership changed).</span>$&%
}

# add button for bouncing a fleet
my($sid,$pid)=($::options{url}=~/\bnr=(\d+).*\bid=(\d+)/);
sub setdest($$$)
{ my($sid,$pid,$text)=@_;
	return qq%<a href="#bounce" onclick="var f=document.fleet; f.planet.value=$pid; if(f.destination2) f.destination2.value=$sid; f.destination.value=$sid; asyncfetchdist($sid);">$text</a>%
}
if($sid && $pid) {
	my $loop=setdest($sid,$pid,"loop fleet");
	s%(<td colspan=")3(" bgcolor='#602020'> <input type="submit".*</td>)%${1}1$2<td colspan="2" bgcolor="#206020">$loop</td><!-- loopmark -->%;

	my $plans=playerid2plans($::options{pid});
	my $pstr="";
	foreach my $plan (@$plans) {
		my($sidpid,$status,$who,$info)=@{$plan}[2..4,8];
		my($sid,$pid)=sidpid32sidpid2m($sidpid);
		my $scolor=getstatuscolor($status);
		my $statusstr=$planetstatusstring{$status};
		$statusstr=~s/ by//;
		my $sysname=systemid2name($sid);
		my $setstr=setdest($sid,$pid,"to $sid#$pid");
#		$pstr.="$setstr @$plan<br/>\n";
		$pstr.="<tr><td bgcolor='$scolor'>$statusstr: <a href=\"/0/Map/Detail.php/?nr=$sid&highlight=$pid\">$sysname#$pid</a></td><td bgcolor='#404040' style='padding-left: 5px' colspan=2>$setstr</td></tr>";
	}
	s{<!-- loopmark --></tr>}{$&$pstr};
#	s{</body>}{<br>$pstr $&};
}

# send-all adjustments
sub replacesendall($)
{
	my $x=shift;
	my $y=$x;
	$x=~s{>all}{>all with transports};
	$y=~s{>all}{>all without transports};
	$y=~s{(inf.value)=\d+}{$1=0};
	return "$y | $x"
}

$ENV{QUERY_STRING}!~m/inf=0/ && s{(<a href="#all".*>all</a>)}{replacesendall($1)}e;

1;
