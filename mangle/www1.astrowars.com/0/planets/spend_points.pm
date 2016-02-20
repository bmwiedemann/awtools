# clear input field
my $script='<script type="text/javascript">document.getElementById("spendPP").points.focus();</script>';
s%</head>%<script type="text/javascript" src="//aw.zq1.de/code/js/planets_spend_points.js"></script>$&%;

if($::options{url}=~/produktion=(\w+)/) {
   my $prod=$1;
   s/name="produktion" value="$prod"/$& checked/;
}
#s%<form id="spendPP" action="submit.php"%$& name="form"%;
s{(<input type="text" name="points"[^>]+/> / )(\d+)}{$1$2 $script};
my $ppthere=$2;

use vkeyboard;
my $vk=vkeyboard("getElementById('spendPP').points",[0..9]);
s%Production Point\(s\)</a> \?%$& $vk%;

if($::options{url}=~/dsCost=(\w+)/) {
   my $basecost=$1;
   my @names=qw"infantrieschiff kolonieschiff destroyer cruiser battleship";
   my @cost=(60,60, $basecost, $basecost*8, $basecost*20);
   my $n2=8;
   if($vk) {$n2+=11}
   for my $n (0..4) {
      my $n3=5+$n;
      my $poss=int($ppthere/$cost[$n]);
      my $ret=s%<input type="radio" id="$names[$n]" name="produktion" value="$names[$n]" />%$&
         <input type="text" class="text" size="4" onblur="update_field(0, $n2, $n3, $cost[$n]);" value="" /> / $poss%;
      # normally we have 2 fields per entry and make 3, but if Math<15, it is only 1 in that row.
      $n2+=1+$ret;
   }
#   s%<input type="radio" name="produktion" value="cruiser">%$& <input type="text" class="text" size="4" onchange="update_field(0, 9, 28); document.form.produktion[7].checked=true " value="2" />%;
}

s{<input type="text" ([^/>]+/> / )(\d+)}
 {<input type="number" min="0" max="$2" $1$2}g;

1;
