# clear input field
my $script='<script language="javascript" type="text/javascript">document.form.points.focus();</script>';
s%</head>%<script type="text/javascript" src="http://aw.lsmod.de/code/js/planets_spend_points.js"></script>$&%;

my $points="";
if($::options{url}=~/points=(\d+)/) {$points=$1}
if($::options{url}=~/produktion=(\w+)/) {
   my $prod=$1;
   s/name="produktion" value="$prod"/$& checked/;
}
s%<form action="/0/Planets/submit.php"%$& name="form"%;
s/(<input type="text" name="points" size="3" class=text value=")(\d+)("\s*> \/ \d+)/$1$points$3 <a class="awtools" href="#all" onClick="document.form.points.value=$2;">all<\/a> $script/;
my $ppthere=$2;

if($::options{url}=~/dscost=(\w+)/) {
   my $basecost=$1;
   my @names=qw"infantrieschiff kolonieschiff destroyer cruiser battleship";
   my @cost=(60,60, $basecost, $basecost*8, $basecost*20);
   my $n2=3;
   for my $n (0..4) {
      my $n3=2*$n+1;
      my $poss=int($ppthere/$cost[$n]);
      my $ret=s%<input type="radio" name="produktion" value="$names[$n]">%$&
         <input type="text" class="text" size="4" onblur="update_field(0, $n2, $n3, $cost[$n]);" value=""></td><td> / $poss%;
      # normally we have 2 fields per entry and make 3, but if Math<15, it is only 1 in that row.
      $n2+=1+2*$ret;
   }
#   s%<input type="radio" name="produktion" value="cruiser">%$& <input type="text" class="text" size="4" onchange="update_field(0, 9, 28); document.form.produktion[7].checked=true " value="2">%;
}

1;
