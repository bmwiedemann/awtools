#!/usr/bin/perl -w

use strict;
use Getopt::Long;

alarm(60);
our (@sci,@pop,@cul,@prod,@planet,%player,$turn,$debug,%options);
our @buildings=qw"hf rf gc rl sb";
our $updatetime=4; # update each quarter hour
#our %racebonus=qw(pop 0.13 pp 0.05 cul 0.05 sci 0.11);
our %racebonus=qw(pop 0.10 pp 0.04 cul 0.04 sci 0.10);
%options=qw(
init 2
initialp 3
tactic 3
turns 400
print 4
adprice 0.94
social 0.5
); # simulate 8 weeks
our %artifact=qw(BM1 3300 BM2 12000 BM3 25000);
our %artifactbonus=qw(BM cul CP pop CD pp AL sci);

my @options=qw"tactic|t=i init|i=i initialp=i turns=i print|p=i pop=i pp=i cul=i sci=i social=f help|h|?";
my $result=GetOptions(\%options, @options);
if(!$result or @ARGV or $options{help}) {
  print "usage $0 [--param=value]\n\tallowable params: @options\n";
  exit(0);
}
if($options{initialp}>250) {$options{initialp}=250}

open(IN, "< input") or die $!;

while(<IN>) {
	if(/science/) {
		for my $l(1..35) {
			$sci[$l]=<IN>;
		}
	}
	if(/population/) {
		for my $l(2..28) {
			$pop[$l]=<IN>;
		}
	}
	if(/culture/) {
		for my $l(1..29) {
			$_=<IN>;
			/\d+\s+(\d+)/;
			$cul[$l]=$1;
		}
	}
}

$sci[0]=0;
$pop[0]=0;
$pop[1]=0;
$cul[0]=0;
for my $l (0..99) {$prod[$l]=5*1.5**($l-1)}
for my $v (@sci,@pop,@prod) {$v=int($v+0.5);if($debug){print "$v\n"}}

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
}

sub update()
{
  my %bonus;
  my $maxpop=$player{social};
  if($maxpop<10) {$maxpop=5+$maxpop/2}
  $maxpop=int($maxpop);
  foreach(qw(pop pp sci cul)) {
    $bonus{$_}=$player{"race$_"}+$player{tas}*0.07;
  }
  if($player{artifact}=~/(.*)(\d)/) {
    my $whichbonus=$artifactbonus{$1};
    $bonus{$whichbonus}+=$2*0.1; # 10 20 or 30%
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
    my $n=@planet-1;#int(rand(@planet));
#    $planet[$n]{pop}++;
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
  foreach(qw"pp sci social cul ad tas") {
    printf "$_:%.2f ", $player{$_};
  }
  print "art:$player{artifact}\n";
}
sub finish(){
  my $sci=0;
  my $pkt=int($player{cul});
  foreach my $p (@planet) {
    $pkt+=int($$p{pop});
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
  printf "total points: %.2f sci: %.2f\n", $pkt, $sci;
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
  spend1();
  printstate() if($turn % $options{print}==0);
  update();
}
finish();
exit 0;
