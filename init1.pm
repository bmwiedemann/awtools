my $init=0;
{
   my $i=$options{initialp};
   $options{turns}-=$i*$updatetime;
   if($i>2*24) {$init=$i*3-3*24}
   elsif($i>24) {$init=$i*2-24}
   else {$init=$i}
}

$planet[0]{pp}=$init;
$planet[0]{pop}=1;
$planet[0]{hf}=0;
$planet[0]{rf}=0;
$planet[0]{rl}=$options{startuplab}?12:0;
$planet[0]{gc}=0;
$planet[0]{sb}=0;

$player{racepop}=1+0.13*0;
$player{racepp}=1+0.05*0;
$player{racecul}=1+0.05*0;
$player{racesci}=1+0.11*0;
addcul2(\%player, $init);
$player{sci}+=$init;
$player{pp}+=$init;
$player{social}=addsci($player{social}, $init*$options{social});

1;
