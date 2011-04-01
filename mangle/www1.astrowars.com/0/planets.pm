sub calcbonus($$) {
   my($base,$bonus)=@_;                                                         
   $bonus||=0;
   return int($base*(1+$bonus/100));                                            
}

s!(?:Growth [+-]\d+%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;)?Production ([+-]\d+)%</td><td>\d+</td><td>\+(\d+)!"$& = ".calcbonus($2,$1)!e;

s!((?:Production [+-]\d+%</td><td>)|(?:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td>))(\d+)!$1.$2."=".int($2*awinput::getartifactprice("pp")).'A$'!e;

1;
