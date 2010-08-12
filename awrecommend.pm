package awrecommend;
use strict;

# limit buildings to level 14 -> more realistic saved PP

our @buildings=qw"hf rf gc rl sb";
our @longbuildings=qw"hydroponicfarm roboticfactory galacticcybernet researchlab starbase";
our %reason=(hf=>"to increase population for more ranking points while at the same time increasing production and science output", # maybe +trade
rf=>"to increase production output which in turn allows to build other buildings and fleet faster",
gc=>"to increase culture output which allows you to take planets earlier and thus to improve overall economy", # maybe +trade
rl=>"to increase science output which allows you to finish science-levels faster",
sb=>"to better defend your planet"
);

our %buildingname;
our @prod;
for my $l (0..99) {$prod[$l]=int(5*1.5**($l-1)+0.9)}
for my $i (0..4) {
		$buildingname{$buildings[$i]}=$longbuildings[$i];
}
my %rentability=qw"hf 0.9 rf 1.6 gc 1 rl 0.58 sb 0.4";
my %max=qw(hf 13 rf 13 gc 13 rl 13 sb 0);
my %rfdepend=(hf=>1/96, rf=>0, gc=>1/14, rl=>1/32, sb=>0);
#my %rentability=qw"hf 1.2 rf 1.5 gc 1 rl 0.8 sb 0.0004";
#my %rentability=qw"hf 0.9 rf 1 gc 1 rl 1 sb 1";
my %options=(turns=>1);
my $updatetime=1;
my $turn=0;

sub buildcost($) { my($level)=@_;
  my $cost=$prod[$level+1];
  my $su=1500;
  if($cost>$su) {$cost=$su}
  return $cost;
}

# returns value>0
sub rentability($$){my ($p,$building)=@_;
  my $rf=$$p{"rf"};
  my $result=$rentability{$building};
  my $eog=9000; 
  if($options{turns}>$eog) {$eog=$options{turns}}
  if($$p{$building}>=$max{$building}) {return 0.00001}
  $result+=$rf*$rfdepend{$building};
  if($building eq "rl" and $rf<6) {return 0.3}
  if($building eq "gc" and $rf<4) {return 0.3}
  if($building eq "rf" or $building eq "rl") { # end-of-round special case
    if(buildcost($$p{$building})*$updatetime>$eog-$turn) { return 0.0001; }
  }
  return $result;
}


sub planet_building_recommend(%)
{
	my $data=shift;
	my ($building, $pp, $level, $reason);
	my $p;
	foreach my $i (0..4) {
		$p->{$buildings[$i]}=int($data->{$longbuildings[$i]}->{num});
	}
	my ($min);
	for my $t(@buildings) {
		if($$p{$t}>=$max{$t}){next}
		my $val=buildcost($$p{$t})/rentability($p,$t);
		#    print "$t:$val ";
		if(!defined($min) || $val<$min) {
			$min=$val;
			$building=$t;
		}
	}
	$pp=$data->{$buildingname{$building}}->{remain};
	return undef if($pp>$data->{productionpoints}->{num}); # only recommend affordable items
	$level=$p->{$building}+1;
	$reason=$reason{$building};
	return {building=>$building, pp=>$pp, level=>$level, reason=>$reason};
}

sub get_recommendation_text($)
{
	my $rec=shift;
	if($rec && $rec->{building}) {
		return "The Brownie economic advisor recommends to raise \U$rec->{building}\E to level $rec->{level} for $rec->{pp} PP $rec->{reason}.";
	} else {
		return "greenbirds error with recommendations?";
	}
}

sub get_recommendation_build_url($$)
{
	my($data,$rec)=@_;
	my $b=$rec->{building};
	my $type;
	for my $i (0..4) { if($buildings[$i] eq $b) {$type=$i; last} }
	require awstandard;
	awstandard::build_url({i=>$data->{n}-1,points=>$rec->{pp}, type=>$type});
}

1;
