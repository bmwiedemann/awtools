sub calcbonus($$) {
   my($base,$bonus)=@_;                                                         
   $bonus||=0;
   return int($base*(1+$bonus/100));                                            
}

s!(?:Growth [+-]\d+%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;)?Production ([+-]\d+)%</td><td>\d+</td><td>\+(\d+)!"$& = ".calcbonus($2,$1)!ge;

1;
