#!/usr/bin/perl -w

use strict;
use Getopt::Long;

our (@sci,@pop,@cul,@prod,@planet,%player,$turn,$debug,%options);
our @buildings=qw"hf rf gc rl sb";
our $updatetime=4; # update each quarter hour
our %racebonus=qw(pop 0.13 pp 0.05 cul 0.05 sci 0.11);
%options=qw(
init 1
tactic 3
turns 400
print 4
); # simulate 8 weeks

my @options=qw"tactic|t=i init|i=i turns=i print|p=i pop=i pp=i cul=i sci=i help|h|?";
my $result=GetOptions(\%options, @options);
if(!$result or @ARGV or $options{help}) {
  print "usage $0 [--param=value]\n\tallowable params: @options\n";
  exit(0);
}

open(IN, "< input") or die $!;

while(<IN>) {
	if(/science/) {
		for my $l(1..28) {
			$sci[$l]=<IN>;
		}
	}
	if(/population/) {
		for my $l(2..28) {
			$pop[$l]=<IN>;
		}
	}
	if(/culture/) {
		for my $l(1..25) {
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

sub update()
{
  for my $planet(@planet) {
    my $pop=int($$planet{pop});
    my $ppp=($$planet{rf}+$pop)*$player{racepp}/$updatetime;
    $$planet{pp}+=$ppp;
    $player{pp}+=$ppp;
    $player{sci}+=(($$planet{rl}+$pop)*$player{racesci})/$updatetime;
    $player{cul}+=(($$planet{gc})*$player{racecul})/$cul[int($player{cul})+1]/$updatetime;
    $$planet{pop}+=$player{racepop}*($$planet{hf}+1.00000001)/$pop[int($$planet{pop})+1]/$updatetime;
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
  foreach(qw"pp sci cul") {
    printf "$_:%.2f ", $player{$_};
}
  print "\n";
}
sub finish(){
  my $sci=0;
  my $pkt=int($player{cul});
  foreach my $p (@planet) {
    $pkt+=int($$p{pop});
  }
  while(1){
    $player{sci}-=$sci[$sci+1]*6;
    last if($player{sci}<0);
    $sci++;
  }
  if($sci>20) {
    $pkt+=6*($sci-20);
  }
  print "total points: $pkt sci: $sci\n";
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
$player{racepop}=1;
$player{racepp}=1;
$player{racecul}=1;
$player{racesci}=1;
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
