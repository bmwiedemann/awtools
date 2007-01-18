# correct signs with points to reduce people's confusion with in-game races

my %neg=(
      "+"=>"-",
      "-"=>"+");
s!<td>([+-])([1-6])</td>!<td>$neg{$1}$2</td>!g;

# colorize bad and non-recommended races
my $badlimit=-25;
my $nrlimit=-13;

#s!h1>Create your own race!$& - <span style="color:red">plus/minus changed by brownie</span> <i>modified by <span style="color:green">greenbird</span> to help you choosing good races... <span class="bad">red=bad</span>, <span class="nr">yellow=not recommended</span></i>!;
s!(h1>Create your own race)(\!</h1>)!$1$2<i>modified by <span style="color:green">greenbird</span> to help you choosing good races... <span class="bad">red=bad (below $badlimit\%)</span>, <span class="nr">yellow=not recommended (below $nrlimit%)</span></i> oh and <span style="color:red">plus/minus changed by brownie to reduce people's confusion with in-game races</span>!;

s%type="text/css"><!--%$&\n.bad { color : #f66;}\n.nr { color : #fd0;}%;
s!(colspan="2")>(-\d{1,2})(%</td>)!$2>$badlimit?"$1>$2$3":"$1 class=\"bad\">$2$3"!ge;
s!(colspan="2")>(-\d{1,2})(%</td>)!$2>$nrlimit?"$1>$2$3":"$1 class=\"nr\">$2$3"!ge;

1;
