use strict;
use DBAccess;

# add artifact number info
if(1 || $mangle::dispatch::g) {
   our %artmap=(1=>"bm", 2=>"al", 4=>"cp", 8=>"cd", 5=>"cr", 10=>"mj", 15=>"hor");
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
      return int(0.5+(($p-1)*100)**(1.588971268));
   }
   s%<th scope="col">Price%<th scope="col">Num</th>$&%;
   s%(<a href="?Stats/)([0-9a-z-]+)(\.html"?>[^<]+</a></td>)\s*(<td>\$)([0-9.,-]+)%"$1$2$3<td>".maparti($2,$5)."</td>$4$5"%gme;
   
   s%</body>%<span style="color:green">note: added number of total units sold in galaxy to artifacts table</span>$&%;
}

s{<table width="300"}{<table class="outersubtable"}g;
s{ width="300">}{class="innersubtable">}g;

1;
