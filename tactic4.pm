my %rentability=qw"hf 0.9 rf 1.7 gc 1 rl 0.7 sb 0.4";
my %max=qw(hf 13 rf 13 gc 99 rl 13 sb 0);
#my %rentability=qw"hf 1.2 rf 1.5 gc 1 rl 0.8 sb 0.0004";
#my %rentability=qw"hf 0.9 rf 1 gc 1 rl 1 sb 1";

# returns value>0
sub rentability($$){my ($p,$building)=@_;
  my $rf=$$p{"rf"};
  my $result=$rentability{$building};
  my $eog=6000; 
  if($options{turns}>$eog) {$eog=$options{turns}}
  if($$p{$building}>=$max{$building}) {return 0.00001}
  if($building eq "gc") {
    $result+=$rf/15;
  }
  if($building eq "rl") {
    $result+=$rf/35;
  }
  if($building eq "rl" and $rf<6) {return 0.0001}
  if($building eq "rf" or $building eq "rl") {
    if(buildcost($$p{$building})*$updatetime>$eog-$turn) { return 0.0001; }
  }
  return $result;
}

sub findtarget($) { my($p)=@_;
  my ($min,$mint);
  for my $t(@buildings) {
    if($$p{$t}>=$max{$t}){next}
    my $val=buildcost($$p{$t})/rentability($p,$t);
#    print "$t:$val ";
    if(!defined($min) || $val<$min) {
      $min=$val;
      $mint=$t;
    }
  }
#  print "$mint:$min\n";
  return $mint;
}

sub spend1()
{ 
  $player{artifact}=~/(\d)$/;
  my $artifactlevel=$1 || 0;
  if(($turn-2000)/1400 > $artifactlevel && $artifactlevel<3) {
	spend_all();
	my $na=$artifactlevel+1; # desired level
	my $oldcost=$artifact{"BM$artifactlevel"} || 0;
	if($player{ad}>=$artifact{"BM$na"}) {
		$player{ad}-=$artifact{"BM$na"}-$oldcost;
		$player{artifact}="BM$na";
	}
  }
  if(($turn-3000)/672 > $player{tas} && $player{tas}<5) {
	spend_all();
	if($player{ad}>=20000) { $player{tas}++; $player{ad}-=20000; }
  }
  foreach my $p (@planet) {
#    my $val=$$p{rf}+$$p{pop};
    if(int($player{cul})>@planet) { # new planet
      my $n=@planet;
      $planet[0]{pp}-=60;
      initplanet(\%{$planet[$n]});
      for(my $np=0; $np<$n; $np++) {
	      if($planet[$np]{pp}>0) {
		my $rate=1.0-$n*0.05;
		if($rate<0.2) {$rate=0.2}
		$planet[$n]{pp}+=$planet[$np]{pp}*$rate;
		$planet[$np]{pp}=0;
	      }
      }
    }
    do {
      $target=findtarget($p);
    } while(defined($target) && build($p,$target,0));
  }
}

1;
