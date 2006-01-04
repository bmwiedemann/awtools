# emphasize important incomings 
sub mangle_incoming() {
s%(<b>Attention !!!</b> We have evidence of an incoming fleet around that time. <br>)(\d+ Transports.*?going to attack)%$1<span style="background-color:#800">$2</span>%g;
}

1;
