use strict;
use DBAccess;
s%<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" bgcolor='#000000' width="600"%$& class="main_inner" id="trade"%;


# add artifact number info
if(1 || $mangle::dispatch::g) {
   our %artmap=(1=>"bm", 2=>"al", 4=>"cp", 8=>"cd", 3=>"cr", 12=>"mj", 15=>"hor");
   sub maparti($$) {
      my($code,$price)=@_;
      my $art;
      $price=~s/\.//g;
      $price=~s/,/./;
      if($code eq "supplyunit" && $price>=1000) { $art="su" }
      elsif($code=~/(\d+)-(\d+)/) { $art=$artmap{$1}.$2 }
      if(!$art) { return "?" }
      my($baseprice)=get_one_row("SELECT `price` FROM `prices` WHERE `item`=?", ["b".$art]);
      return "" if not $baseprice;
      my $p=$price/$baseprice;
      return int(0.5+(($p-1)*100)**(log(3)/log(2)));
   }
   s%<td colspan="2"><b>Prices</b>%<td colspan="3"><b>Prices</b>%;
   s%(<a href="?Stats/)([0-9a-z-]+)(\.html"?>[^<]+</a></td>)(<td align=right>\$)([0-9.,-]+)%"$1$2$3<td>".maparti($2,$5)."</td>$4$5"%ge;
   
   s%</body>%<span style="color:green">note: added number of total units sold in galaxy to artifacts table</span>$&%;
}

1;
