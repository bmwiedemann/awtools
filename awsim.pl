#!/usr/bin/perl -w

use strict;

our (@sci,@pop,@prod,@planet,%player,$turn,$debug,%options);
our @buildings=qw"hf rf gc rl sb";

%options=qw;
init 1
tactic 3
turns 70
print 15
;;

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
}

$sci[0]=0;
$pop[0]=0;
$pop[1]=0;
for my $l (0..28) {$prod[$l]=5*1.5**($l-1)}
for my $v (@sci,@pop,@prod) {$v=int($v+0.5);if($debug){print "$v\n"}}

sub build($$$)
{ my($p,$what,$rem)=@_;
	my $l=$$p{$what};
	if($$p{pp}>=$prod[$l+1]+$rem) {
		$$p{$what}++;
		$$p{pp}-=$prod[$l+1];
		return 1;
	}
	return 0;
}

sub update()
{
  for my $planet(@planet) {
    my $pop=int($$planet{pop});
    my $ppp=$$planet{rf}+$pop;
    $$planet{pp}+=$ppp;
    $$planet{pop}+=($$planet{hf}+1)/$pop[int($$planet{pop})+1]+0.0001;
    $player{sci}+=$$planet{rl}+$pop;
    $player{cul}+=$$planet{gc};
    $player{pp}+=$ppp;
  }
}

my $tactic=shift(@ARGV)||"tactic1.pm";
#$options{turns}=shift(@ARGV)||"70";
require $tactic;

sub printstate()
{
  print "turn $turn: ";
  foreach my $p (@planet) {
    printf("pop:%.2f  ",$$p{pop});
    foreach my $b(@buildings, "pp") {
      my $v=$$p{$b};
      if(length($v)<2) {$v.=" "}
      print "$b:$v ";
    }
    print " ";
    while(my @a=each(%player)) {
      print "$a[0]:$a[1] ";
    }
    print "\n";
  }
}
sub finish(){}

$player{cul}=0;
$player{sci}=0;
$player{pp}=0;
require "init".$options{init}.".pm";


for $turn(0..$options{turns}) {
  spend1();
  printstate() if($turn % $options{print}==0);
  update();
}
finish();
