use awstandard;
use awinput;
use Time::HiRes;

# activate arrival calc checkbox
s/<input type="checkbox" name="calc" value="1"/$& checked/;


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
   my $ret='<select name="planet">';
   for my $i (1..12) {
      my $sel=$_[0]==$i?" selected":"";
      $ret.=qq%<option$sel>$i</option>%;
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
   if(defined($refs) && defined($refe) && $srcsid && defined(@c1)) {
      $refs=1+$refs*$awstandard::racebonus[4];
      s%</head>%<script type="text/javascript" src="http://aw.lsmod.de/code/js/arrival.js"></script>$&%;
      
      my @distlist;
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
            }
            $o||=0;
            $own.=",$o";
         }
         next if(!defined(@c2));
         my $dist=($c2[0]-$c1[0])**2 + ($c2[1]-$c1[1])**2;
         push(@distlist, "disttable[$sid]=[$dist$own];\n");
      }
      my $starttime=sprintf("%i.%.6i ;", Time::HiRes::gettimeofday());
      s%</form>%$& <form><input class="text" name="travel" size="9" disabled> <input class="text" name="arrival" size="28" disabled></form>
      <script type="text/javascript">
         <!--
         @distlist;
         energy=$refe;
         racebonus=$refs;
         starttime=$starttime
         var startdiff = (startd.getTime()/1000) - starttime;
      //-->
      </script>%;
   }
   s%</body>%<span class="bmwnotice">note: predicted arrival time will be wrong if your local clock is wrong (or target ownership changed).</span>$&%
}

1;
