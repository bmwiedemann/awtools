#!/usr/bin/perl -w
use strict;
require "input.pm";

my %relation;
my %nsystems;

for my $sid (1..6000) {
 my %allis=();
 my $level=systemid2level($sid);
 for my $plid (1..12) {
	my $p=getplanet($sid, $plid);
	my $o=$$p{ownerid};
	if(!$o || $o<=2) {next}
	my $aid=playerid2alliance($o);
	if(!$aid) {next}
	if($::alliances{$aid}{points}<270 && allianceid2members($aid)<10) {next}
	$allis{$aid}++;
 }
 foreach my $a1 (keys %allis) {
  foreach my $a2 (keys %allis) {
	next if $a1==$a2;
	$relation{"$a1,$a2"}+=$level;#*$allis{$a1}*$allis{$a2};
	$nsystems{"$a1,$a2"}++;
  }
 }
}

sub sortfunc { return $relation{$b}<=>$relation{$a} }
#sub sortfunc { return $nsystems{$b}<=>$nsystems{$a} }

foreach my $rel (sort sortfunc keys %relation) {
	my @a=split(",",$rel);
	if($a[0]>=$a[1]) {next}
	$a[0]=allianceid2tag($a[0]);
	$a[1]=allianceid2tag($a[1]);
	print "$a[0] -- $a[1]; //$relation{$rel} $nsystems{$rel}\n";
}
