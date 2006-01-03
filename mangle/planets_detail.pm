my @buildings=("Hydroponic Farm", "Robotic Factory", "Galactic Cybernet", "Research Lab", "Starbase");
my @val=qw(farm fabrik kultur forschungslabor starbase);
#my $debug="";

$::options{url}=~/i=(\d+)/;
my $planet=$1;
m%Production Points</a></td><td>\s*(\d+)</td>%;
my $pp=$1;


my $n=0;
foreach my $buil (@buildings) {
   next if(! m%($buil</a></td><td>)(\d+)(.*?\n<td> *)(\d+)(</td></tr>)%);
   my ($level,$ppneeded)=($2,$4);
   next if($ppneeded>1000 || $ppneeded>$pp);
   s%($buil</a></td><td>)(\d+)(.*?\n<td> *)(\d+)(</td></tr>)%$1$2$3$4 <a href="/0/Planets/Spend_Points.php/?p=$pp&amp;i=$planet&amp;points=$4&amp;produktion=$val[$n]" style="background-color:red">+1</a>$5%;
#   $debug.="<br>test: $buil $val[$n] $2 $4";
   $n++;
}

#$_.=$debug;

1;
