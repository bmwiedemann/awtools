use strict;
use awstandard;
use awinput;

my @buildings=("Hydroponic Farm", "Robotic Factory", "Galactic Cybernet", "Research Lab", "Starbase");
my @val=qw(farm fabrik kultur forschungslabor starbase);
my $debug="";

$::options{url}=~/i=(\d+)/;
my $planet=$1;
m%Production Points</a></td><td>\s*(\d+)</td>%;
my $pp=$1;
my $sidpid;
my ($popplus,$pop,$popneeded)= (m%id=23>\+(\d+)</a></td><td>\s*(\d+)</td>.*\n(\d+)</td></tr>%);
#   $debug.=" $popplus $pop $popneeded ";
my($ppplus)=(m%id=23>\+(\d+)</a>\n%);
#   $debug.=$ppplus;

sub manglesys($$) {my($sysname, $planet)=@_;
   my $result="$sysname #$planet";
   my $sid=systemname2id($sysname);
   if($sid) {
      $sidpid=sidpid22sidpid3m($sid, $planet);
      my ($x,$y)=systemid2coord($sid);
      return "<a href=\"/0/Map/Detail.php/?nr=$sid\">$sysname #$planet ($x,$y) id=$sid</a>";
   }
   return $result;
}

s%^([^<]+) (\d{1,2})(</td></tr>)%manglesys($1, $2).$3%me;

# find and pass cost of destroyer
my $dscost="";
if(m%/0/Glossary//\?id=17> Destroyer.*\n<td colspan="2">\d+/(\d+)</td></tr>%) {
   $dscost="&amp;dscost=$1";
   s%(<td><a href="/0/Planets/Spend_Points.php/\?p=\d+&i=\d+)("><b>Spend Points</b></a></td>)%$1$dscost$2%;
}


my $realpp=$pp;
# show production points as float
if(1) {
   if((my($pp,$p1,$p2)=(m%id=21>Production Points</a></td><td> (\d+)</td><td><img src="/images/dot.gif" height="10" width="([0-9.]+)"><img src="/images/leer.gif" height="10" width="([0-9.]+)"></td>%))) {
   my $frac=$p1/($p1+$p2);
   $realpp=$pp+$frac;
   $pp=sprintf("%.2f",$realpp);
   s%id=(21>Production Points</a></td><td>) (\d+)%$1 $pp%;
#   $_.="test $pp $p1 $p2 $frac";
   }
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
 } elsif((my $p=$player{$::options{pid}})) {
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
      my $hours=sprintf("<span style=\"color:gray\">in&nbsp;%.1fh&nbsp;(%i%%)</style>",($ppneeded-$realpp)/$ppplus/$prodbonus, 100*$prodbonus);
      s%($buil)(</a></td><td>)(\d+)(.*?\n<td> *)(\d+)(</td></tr>)%$1$2$3$4$5&nbsp;$hours$6%;
      next;
   }
   next if(($ppneeded>1000 && $buil ne "Starbase") || $ppneeded>$pp);
   s%($buil)(</a></td><td>)(\d+)(.*?\n<td> *)(\d+)(</td></tr>)%$1$2$3$4$5 <a href="/0/Planets/Spend_Points.php/?p=$pp&amp;i=$planet&amp;points=$5&amp;produktion=$val[$n]$dscost" style="background-color:blue">+1</a>$6%;
#   $debug.="<br>test: $buil $val[$n] $2 $4";
}

if($popplus && $popbonus) { # add hours to pop-growth
   my $hours=sprintf("<span style=\"color:gray\">in&nbsp;%.1fh&nbsp;(%i%%)</style>", $popneeded/$popplus/$popbonus, 100*$popbonus);
   s%(id=23>\+\d+</a></td><td>\s*\d+</td>.*\n\d+)(</td></tr>)%$1&nbsp;$hours$2%;
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
$_.=$debug;

1;
