my @buildings=("Hydroponic Farm", "Robotic Factory", "Galactic Cybernet", "Research Lab", "Starbase");
my @val=qw(farm fabrik kultur forschungslabor starbase);
#my $debug="";

$::options{url}=~/i=(\d+)/;
my $planet=$1;
m%Production Points</a></td><td>\s*(\d+)</td>%;
my $pp=$1;

sub manglesys($$) {my($sysname, $planet)=@_;
   my $result="$sysname #$planet";
   my $sid=systemname2id($sysname);
   if($sid) {
      my ($x,$y)=systemid2coord($sid);
      return "<a href=\"/0/Map/Detail.php/?nr=$sid\">$sysname #$planet ($x,$y) id=$sid</a>";
   }
   return $result;
}

s%^([^<]+) (\d{1,2})(</td></tr>)%manglesys($1, $2).$3%me;

foreach my $n (0..$#buildings) {
   my $buil=$buildings[$n];
   next if(! m%($buil</a></td><td>)(\d+)(.*?\n<td> *)(\d+)(</td></tr>)%);
   my ($level,$ppneeded)=($2,$4);
   next if(($ppneeded>1000 && $buil ne "Starbase") || $ppneeded>$pp);
   s%($buil</a></td><td>)(\d+)(.*?\n<td> *)(\d+)(</td></tr>)%$1$2$3$4 <a href="/0/Planets/Spend_Points.php/?p=$pp&amp;i=$planet&amp;points=$4&amp;produktion=$val[$n]" style="background-color:blue">+1</a>$5%;
#   $debug.="<br>test: $buil $val[$n] $2 $4";
}

#$_.=$debug;

1;
