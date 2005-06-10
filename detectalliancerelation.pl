#!/usr/bin/perl -w
use strict;
require "input.pm";

my %relation;
my %nsystems;

for my $sid (1..6000) {
 my %allis=();
 my $level=systemid2level($sid);
 my $minpop=100;
 for my $plid (1..12) {
	my $p=getplanet($sid, $plid);
	my $o=planet2owner($p);
	my $pop=planet2opop($p);
	if(!$o || $o<=2) {next}
	if($pop<$minpop) {$minpop=$pop}
	my $aid=playerid2alliance($o);
	if(!$aid) {next}
	if($::alliances{$aid}{points}<270 && allianceid2members($aid)<8) {next}
	$allis{$aid}++;
 }
 foreach my $a1 (keys %allis) {
  foreach my $a2 (keys %allis) {
	next if $a1==$a2;
	#if($a1==19 && $a2==96) {print "$sid\n"}
	$relation{"$a1,$a2"}+=$minpop;#*$allis{$a1}*$allis{$a2};
	$nsystems{"$a1,$a2"}++;
  }
 }
}

#sub sortfunc { return $relation{$b}<=>$relation{$a} }
sub sortfunc { return $nsystems{$b}<=>$nsystems{$a} || $relation{$b}<=>$relation{$a}}

foreach my $rel (sort sortfunc keys %relation) {
	my @a=split(",",$rel);
	if($a[0]>=$a[1]) {next}
	$a[0]=allianceid2tag($a[0]);
	$a[1]=allianceid2tag($a[1]);
	my $f=sprintf "%.4f",$relation{$rel}/$nsystems{$rel}-6; # friendship rating
	print "$a[0] -- $a[1]; //$relation{$rel} $nsystems{$rel} $f\n";
}
