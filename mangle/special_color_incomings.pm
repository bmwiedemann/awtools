# emphasize important incomings 
sub mangle_incoming() {
#going to attack <b>Alpha Kelb Alrai</b>          [914] 2
s%(going to attack )(<b>[^<]*</b>\s*)\[(\d+)\]( \d+)%$1$::bmwlink/system-info?id=$3">$2 [$3]</a>$4%g;

s%(<b>Attention !!!</b> We have evidence of an incoming fleet around that time. <br>)(\d+ Transports.*?going to attack)%$1<span style="background-color:#800">$2</span>%g;
}

1;
