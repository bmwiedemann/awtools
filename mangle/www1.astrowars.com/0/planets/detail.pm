use strict;
use awstandard;
use awinput;
use parse::dispatch;
my $data=parse::dispatch::dispatch(\%::options);

my @buildings=("Hydroponic Farm", "Robotic Factory", "Galactic Cybernet", "Research Lab", "Starbase");
my $debug="";

my($planet)=($::options{url}=~/i=(\d+)/);
if($planet != $data->{n}-1) {
   s/#404040/#802020/g;
   s/(body.*"#000000">)/$&\n<div style="background-color: #300">/;
	s%</body>%<br/><span class=bmwwarning>warning: You should not spend PP on this page as they would go to planet 7 (that is an old AW bug). Refresh and then spend your PPs.</span><br/>$&%;
}

# add access keys
s{>Previous</a></td>}{ accesskey="p" $&};
s{>Next</a></td>}{ accesskey="n" $&};
# end


m%Production Points</a></td><td>\s*(\d+)</td>%;
my $pp=$data->{productionpoints}->{num};
my($ppplus)=$data->{productionpoints}->{hourly};
my $sidpid;
my ($popplus,$pop,$popneeded)= map{$data->{population}->{$_}} qw(hourly num remain);
#   $debug.=" $popplus $pop $popneeded ";
#   $debug.=$ppplus;

sub manglesys($$) {my($sysname, $planet)=@_;
   my $result="$sysname #$planet";
   my $sid=systemname2id($sysname);
   if($sid) {
      $sidpid=sidpid22sidpid3m($sid, $planet);
      my ($x,$y)=systemid2coord($sid);
      return "<a href=\"/0/Map/Detail.php/?nr=$sid&highlight=$planet\">$sysname #$planet ($x,$y) id=$sid</a>";
   }
   return $result;
}

s%^([^<]+) (\d{1,2})(</td></tr>)%manglesys($1, $2).$3%me;

# find and pass cost of destroyer
my $dscost="";
if(m%/0/Glossary//\?id=17> Destroyer.*\n<td colspan="2">\d+/(\d+)</td></tr>%) {
   $dscost="&amp;dscost=$1";
   s%(<td><a href="/0/Planets/Spend_Points.php/\?p=\d+&)(i=\d+)("><b>Spend Points</b></a></td>)%$1amp;$2$dscost$3%;
}


my $realpp=$pp;
# show production points as float
if(1) {
#   if((my($pp,$p1,$p2)=(m%id=21>Production Points</a></td><td> (\d+)</td><td><img src="/images/dot.gif" height="10" width="([0-9.]+)"><img src="/images/leer.gif" height="10" width="([0-9.]+)"></td>%))) {
#   my $frac=$p1/($p1+$p2);
#   $realpp=$pp+$frac;
   $pp=sprintf("%.2f",$realpp);
   s%id=(21>Production Points</a></td><td>) (\d+)%$1 $pp%;
#   $_.="test $pp $p1 $p2 $frac";
#   }
}


my $prodbonus=1;
my $popbonus=1;
if($::options{name}) {
 if($ENV{REMOTE_USER}) { # use real race info - only for extended tools users
   my $prod=playerid2production($::options{pid});
   my $bonus=pop(@$prod);
   if($bonus) {
      $popbonus=$bonus->[3];
      $prodbonus=$bonus->[0];
   }
#   my ($race,$sci)=awinput::playername2ir($::options{name});
#   if($race && defined($$race[0])) {
#      $popbonus+=$awstandard::racebonus[0]*$$race[0];
#      $prodbonus+=$awstandard::racebonus[3]*$$race[3];
#      $_.="@$race $popbonus $prodbonus";
#   }
 } elsif((my $p=getplayer($::options{pid}))) {
    $prodbonus+=0.01*$p->{trade};
    $popbonus+=0.01*$p->{trade};
 }
}

# add +1 build links when there is enough PP
foreach my $n (0..$#buildings) {
   my $buil=$buildings[$n];
   next if(! m%($buil</a></td><td>)(\d+)(.*?\n<td> *)(\d+)(</td></tr>)%);
   my ($level,$ppneeded)=($2,$4);
   if($mangle::dispatch::g) {
#      $debug.="$level $ppneeded<br>";
   }
   if($ppneeded>$pp && $ppplus && $prodbonus) {
      my $hours=sprintf("<span style=\"color:gray\">in&nbsp;%.1fh&nbsp;(%0.f%%)</span>",($ppneeded-$realpp)/$ppplus/$prodbonus, 100*$prodbonus);
      s%($buil)(</a></td><td>)(\d+)(.*?\n<td> *)(\d+)(</td></tr>)%$1$2$3$4$5&nbsp;$hours$6%;
      next;
   }
   next if(($ppneeded>1500 && $buil ne "Starbase") || $ppneeded>$pp);

	my $onclickjs=qq%
	var d=document.getElementById('spenddiv');
	d.style.display='inline';
	var l=document.getElementById('spendlink$n');
	l.href='#';
	document.form.building$n.checked=true;
	document.form.points.focus();
	document.form.points.select();
	%;
   #$onclickjs="";

	my $intpp=int($pp);
   s%($buil)(</a></td><td>)(\d+)(.*?\n<td> *)(\d+)(</td></tr>)%$1$2$3$4$5 <a id="spendlink$n" href="/0/Planets/Spend_Points.php/?p=$intpp&amp;i=$planet&amp;points=$5&amp;produktion=$awstandard::buildingval[$n]$dscost" style="background-color:blue" onclick="
	document.form.points.value='$5'; $onclickjs">+1</a>$6%;
#   $debug.="<br>test: $buil $val[$n] $2 $4";
}

if($popplus && $popbonus) { # add hours to pop-growth
   my $hours=sprintf("<span style=\"color:gray\">in&nbsp;%.1fh&nbsp;(%i%%)</span>", $popneeded/$popplus/$popbonus, 100*$popbonus);
   s%(id=23>\+\d+</a></td><td>\s*\d+</td>.*\n\d+)(</td></tr>)%$1&nbsp;$hours$2%;
}

# add SB auto-growth
my $sb=$data->{starbase}->{num};
if($sb) {
	my $hours=sprintf("<span style=\"color:green\">in&nbsp;%.1fh</span>", $data->{starbase}->{remain}/($sb*0.2));
	my $buil="Starbase";
	s%($buil)(</a></td><td>)(\d+)(.*?\n<td> *)(\d+)%$1$2$3$4$5&nbsp;$hours%;
}

# add incomings to this planet below
if(1) {
   my $fleets=awinput::sidpid2fleets($sidpid, "AND `iscurrent` = 1 ");
   my $fstr="";
   foreach my $f (@$fleets) {
      my $fs=awinput::show_fleet($f)."<br>";
      $fs=~s/<a href="(relations\?id=)/$::bmwlink\/$1/;
      $fstr.=$fs;
   }
   if($fstr) {
      s%^</td></tr></table>$%
      </td></tr><tr><td>$fstr
      <br>
      $&%m
   }
}

s%</head>%<script type="text/javascript" src="http://aw.lsmod.de/code/js/planets_spend_points.js"></script>$&%;
my $spend=qq!
<div style="display:none" id="spenddiv">
<table class="main_outer"><tr><td>
<form action="/0/Planets/submit.php" name="form" method="post">
<table class="main_inner" cellspacing="1">
<tr align=center><td bgcolor="#202060">Where to spend <input type="text" name="points" size="4" id="ppvalue" class="text" value="" > <span id="ppmaxvalue"></span> <a class="awtools" href="#all" onClick="document.form.points.value=!.int($pp).qq!;">all</a> <a class="awglossary" href="/0/Glossary//?id=21"> Production Point(s)</a>? </td></tr></table>
<table border="0" cellspacing="1" cellpadding="1" bgcolor='#000000'>
<tr align=center><td bgcolor='#404040' width="135">Hydroponic Farm</td><td><input type="radio" name="produktion" id="building0" value="farm"></td><td bgcolor='#404040' width="135">Transport</td><td><input type="radio" name="produktion" value="infantrieschiff">
         </td></tr>
<tr align=center><td bgcolor='#404040'>Robotic Factory</td><td><input type="radio" name="produktion" id="building1" value="fabrik"></td><td bgcolor='#404040'>Colony Ship</td><td><input type="radio" name="produktion" value="kolonieschiff">
         </td></tr>
<tr align=center><td bgcolor='#404040'>Galactic Cybernet</td><td><input type="radio" name="produktion" id="building2" value="kultur"></td><td bgcolor='#404040'>Destroyer</td><td><input type="radio" name="produktion" value="destroyer">
         </td></tr>

<tr align=center><td bgcolor='#404040'>Research Lab</td><td><input type="radio" name="produktion" id="building3" value="forschungslabor"></td>
<td bgcolor='#404040'>Cruiser</td><td><input type="radio" name="produktion" value="cruiser">
         </td></tr>
<tr align=center><td bgcolor='#404040'>Starbase</td><td><input type="radio" name="produktion" id="building4" value="starbase"></td><td bgcolor='#404040'>Battleship</td><td><input type="radio" name="produktion" value="battleship">
         </td><td><input type="submit" value="Spend PP" class="smbutton">
<input type="hidden" name="i" value="$planet"></td></tr>
</table>
</form>
<a name="spend"></a>
</table>
</div>
</center>
!;

s{</body>}{$spend$&};

$_.=$debug;

1;
