#!/usr/bin/perl

use strict;
use Getopt::Long;
use awstandard;

alarm(60);
srand(0);
our (@sci,@pop,@cul,@prod,@planet,%player,$turn,$debug,%options);
our @buildings=qw"hf rf gc rl sb";
our $updatetime=4; # update each quarter hour
our %racebonus;
{
	my @r=@awstandard::racebonus;
	%racebonus=(pop=>$r[0], sci=>$r[1], cul=>$r[2], pp=>$r[3]);
}
%options=qw(
init 1
initialp 3
tactic 6
turns 400
print 4
activeturns 4
adprice 0.94
social 0.5
trades 1
maxbuilding 14
cdturns 0.66
); # simulate 8 weeks
our %artifact=qw(BM1 3300 BM2 12000 BM3 25000 CD1 3400 CD2 12500 CD3 28000);
our %artifactbonus=qw(BM cul CP pop CD pp AL sci);

#growth = 9(x-1)^2+9(x-1)+3
#prod = 5*1.5^(n-1)

my @options=qw"trader! startuplab! tactic|t=i init|i=i initialp=i turns=i print|p=i pop=i pp=i cul=i sci=i maxbuilding=i activeturns=i social=f trades=f cdturns=f help|h|?";
my $result=GetOptions(\%options, @options);
if(!$result or @ARGV or $options{help}) {
  print "usage $0 [--param=value]\n\tallowable params: @options\n";
  exit(0);
}
#if($options{initialp}>250) {$options{initialp}=250}

open(IN, "< input") or die $!;

while(<IN>) {
	if(/science/) {
		for my $l(1..40) {
			$sci[$l]=<IN>;
		}
	}
	if(/population/) {
		for my $l(2..30) {
			$pop[$l]=<IN>;
		}
	}
	if(/culture/) {
		for my $l(1..32) {
			$_=<IN>;
			/\d+\s+(\d+)/;
			$cul[$l]=$1;
		}
	}
}

for my $n (30..60) {
   $sci[$n]=(((0.00604082*$n +0.138947)*$n+8.46566)*$n+17.3427)*$n+4.40132;
}
for my $n (2..100) {
   $pop[$n]=(9*($n-2) + 27)*($n-2) + 21;
}

sub culval($) {
   my ($n)=@_;
   return (((((0.00982467*$n + 0.221853)*$n + 24.372)*$n + 119.577)*$n + 339.102)*$n -439.814);
}
for my $n (26..60) {
   $cul[$n]=culval($n-1)-culval($n-2);
}

$sci[0]=0;
$pop[0]=0;
$pop[1]=0;
$cul[0]=0;
for my $l (0..99) {$prod[$l]=5*1.5**($l-1)}
for my $v (@sci,@pop,@prod) {$v=int($v+0.5);if($debug){print "$v\n"}}

sub min($$) {return $_[0]<$_[1]?$_[0]:$_[1]}
sub max($$) {return $_[0]>$_[1]?$_[0]:$_[1]}
sub addcul($$) { my($cul,$culp)=@_;
   while((my $needed=$cul[$cul+1]) && $culp>0) {
      my $s=min($needed,$culp);
      $cul+=$s/$needed;
      $culp-=$s;
   }
   return $cul;
}
sub addcul2(%$) {my($player,$culp)=@_; $$player{cul}=addcul($$player{cul}, $culp); }
sub addsci($$) { my($sci,$scip)=@_;
   while((my $needed=$sci[$sci+1]) && $scip>0) {
      my $s=min($needed,$scip);
      $sci+=$s/$needed;
      $scip-=$s;
   }
   return $sci;
}
sub maketradeagreement(%) { my($player)=@_;
   $$player{tas}++;
   if(!$options{trader}) {$$player{ad}-=20000;}
}
sub buyartifact(%$) { my($player,$art)=@_;
   if(!$art) {return}
   my $cost=$artifact{$art};
   if($$player{ad}<$cost) {return}
   my $prevvalue=$artifact{$$player{artifact}} || 0;
   $$player{ad}+=$prevvalue-$cost;
   $$player{artifact}=$art;
}
sub buildcost($) { my($level)=@_;
  my $cost=$prod[$level+1];
  my $su=900;
  if($cost>$su) {$cost=$su}
  return $cost;
}
sub build($$$)
{ my($p,$what,$rem)=@_;
	my $l=$$p{$what};
	if($$p{pp}>=buildcost($l)+$rem) {
		$$p{$what}++;
		$$p{pp}-=buildcost($l);
		return 1;
	}
	return 0;
}

sub spend_all()
{
	foreach my $planet(@planet[0..$#planet-2]) {
		$player{ad}+=$$planet{pp}*$options{adprice};
		$$planet{pp}=0;
	}
   return 1;
}

sub gettradebonus($$) { my($turn,$taplanets)=@_;
   return 0.01*$options{trades}*$taplanets;
}

sub update()
{
  my %bonus;
  my $maxpop=$player{social};
  if($maxpop<10) {$maxpop=5+$maxpop/2}
  $maxpop=int($maxpop);
  my $taplanets=0;
  for my $planet(@planet) {
    my $pop=int($$planet{pop});
    if($pop>=10) {$taplanets++}
  }
  my $tr=$player{tas}*gettradebonus($turn,$taplanets);
  $player{tr}=$tr;
  foreach(qw(pop pp sci cul)) {
    $bonus{$_}=$player{"race$_"}*(1+$tr);
  }
  if($player{artifact}=~/(.*)(\d)/) {
    my $whichbonus=$artifactbonus{$1};
    $bonus{$whichbonus}*=(1+$2*0.1); # 10 20 or 30%
  }
  for my $planet(@planet) {
    my $pop=int($$planet{pop});
    my $ppp=($$planet{rf}+$pop)*$bonus{pp}/$updatetime;
    my $sci=($$planet{rl}+$pop)*$bonus{sci}/$updatetime;
    $$planet{pp}+=$ppp;
    $player{pp}+=$ppp;
    $player{sci}+=$sci;
    if($player{social}<34) {
      $player{social}+=$sci*$options{social}/$sci[int($player{social})+1];
    }
    $player{cul}+=(($$planet{gc})*$bonus{cul})/$cul[int($player{cul})+1]/$updatetime;
    $$planet{pop}+=$bonus{pop}*($$planet{hf}+1.00000001)/$pop[int($$planet{pop})+1]/$updatetime;
    if($$planet{pop}>$maxpop) {$$planet{pop}=$maxpop}
  }
  if($turn%(24*$updatetime)==0) { # daily spontaneous growth
    my @smallplanet=();
    foreach my $p (@planet) {if($$p{pop}<=$player{social}-6){push(@smallplanet,$p)}}
    #my $n=@planet-1;
    #if(@smallplanet) {
    #  my $n=int(rand(@smallplanet));
    #  $smallplanet[$n]{pop}++;
    #}
    foreach my $p (@smallplanet) { $$p{pop}+=1/@smallplanet }
  }
}

#my $tactic=shift(@ARGV)||"tactic1.pm";
#$options{turns}=shift(@ARGV)||"70";
my $tactic="tactic$options{tactic}.pm";
require $tactic;

sub printstate()
{
  my $n=1;
  print "turn $turn (",$turn/$updatetime,"h): \n";
  foreach my $p (@planet) {
    printf("\t%2i pop:%.2f  ", $n++, $$p{pop});
    foreach my $b(@buildings, "pp") {
      my $v=$$p{$b};
      if(length($v)<2) {$v.=" "}
      printf("$b:%i ",$v);
    }
    print "\n";
  }
  #while(my @a=each(%player)) {
    #printf "$a[0]:%.2f ",$a[1];
  foreach(qw"pp sci social cul ad tas tr") {
    printf "$_:%.2f ", $player{$_};
  }
  print "art:$player{artifact}\n";
}
sub finish(){
  my $sci=0;
  my $pkt=0;#int($player{cul});
  foreach my $p (@planet) {
  	 my $pop=$$p{pop};
     next if($pop<10.5);
    $pkt+=$pop-0.5-10;
	 if($pop>20) {$pkt+=$pop-20}
    #$pkt+=int($$p{pop});
  }
  while(1){
    my $scineeded=$sci[$sci+1]*6;
    if($player{sci}>$scineeded) {
	$player{sci}-=$scineeded;
    	$sci++;
    } else {
	    $sci+=$player{sci}/$scineeded;
	    last;
    }
  }
  
  if($sci>20) {
    $pkt+=6*($sci-20);
  }
  spend_all();
  printf "total points: %.2f sci: %.2f cul: %.2f A\$: %i\n", $pkt, $sci, $player{cul}, $player{ad};
}
sub initplanet {my ($p)=@_;
$$p{pp}=0;
$$p{pop}=1;
$$p{hf}=0;
$$p{rf}=0;
$$p{rl}=0;
$$p{gc}=0;
$$p{sb}=0;
}

$player{cul}=1;
$player{sci}=0;
$player{pp}=0;
$player{tas}=0;
$player{ad}=0;
$player{racepop}=1;
$player{racepp}=1;
$player{racecul}=1;
$player{racesci}=1;
$player{artifact}="";
$player{social}=0;
initplanet(\%{$planet[0]});
require "init".$options{init}.".pm";
foreach(qw(pop pp cul sci)) {
	if($options{$_}) {$player{'race'.$_}=1+$racebonus{$_}*$options{$_}}
}

for $turn(0..$options{turns}) {
  if($turn%$options{activeturns}==0) {
     spend1();
  }
  printstate() if($turn % $options{print}==0 || $turn==$options{turns});
  update();
}
finish();
exit 0;
