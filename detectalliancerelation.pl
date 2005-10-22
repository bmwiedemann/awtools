#!/usr/bin/perl -w
# this code is Copyright Bernhard M. Wiedemann and licensed under GNU GPL
use strict;
require "input.pm";

if(scalar keys %::alliances<10) {exit 0}
my %relation;
my %nsystems;
my %conq;
my %killedpop;

#print STDERR "importing old data...\n";
my @olddata;
my @oldpopdata;
for my $day (1..7) {
	my %oldday;
	my %olddaypop;
	my @t=localtime(time()-3600*24*$day);
	my ($d,$m,$y)=(sprintf("%.2i",$t[3]),sprintf("%.2i",$t[4]+1), $t[5]+1900);
	open(F, "tar -Oxjf www1.astrowars.com/export/history/all$d-$m-$y.tar.bz2 planets.csv |") or next;
	my $dummy=<F>;
	while(<F>) {
		next if m/^\s*$/;
		my @a=split("\t");
		my $sidpid="$a[0]#$a[1]";
		$oldday{$sidpid}=$a[4];
		$olddaypop{$sidpid}=$a[2];
#		print "$a[0]#$a[1] $a[4]\n";
	}
	push @olddata, \%oldday;
	push @oldpopdata, \%olddaypop;
}
#print STDERR "scanning systems...\n";

{my $dummy=\%::alliances;} #avoid warning

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
	my $sidpid="$sid#$plid";
	my $n=0;
	foreach my $oldowner (@olddata) {
		my $o2=$$oldowner{$sidpid};
		last unless $o2 && $o2>2;
		if($o2!=$o) {
			my $aid2=playerid2alliance($o2);
			last unless $aid2;
			my $rel="$aid,$aid2";
#			if($aid==82 && $aid2==62) {print "$sidpid ${$oldpopdata[$n]}{$sidpid}\n"}
			$conq{$rel}++;
			$killedpop{$rel}+=${$oldpopdata[$n]}{$sidpid};
			$relation{$rel}+=0; # force entry
			$nsystems{$rel}+=0;
#print "$sidpid $aid2->$aid\n";
			last;
		}
		$n++;
	}
 }
 foreach my $a1 (keys %allis) {
  foreach my $a2 (keys %allis) {
	next if $a1==$a2;
	my $rel="$a1,$a2";
#	if($a1==13 && $a2==61) {print "$sid\n"}
	$relation{$rel}+=$minpop;#*$allis{$a1}*$allis{$a2};
	$nsystems{$rel}++;
  }
 }
}

#sub sortfunc { return $relation{$b}<=>$relation{$a} }
sub sortfunc { return $nsystems{$b}<=>$nsystems{$a} || $relation{$b}<=>$relation{$a}}

#print STDERR "printing results...\n";

foreach my $rel (sort sortfunc keys %relation) {
	my @a=split(",",$rel);
	if($a[0]>=$a[1]) {next}
	my $rrel="$a[1],$a[0]"; # reverse relation
	my $conq1=$conq{$rel}||0;
	my $conq2=$conq{$rrel}||0;
	my $conq=$conq1+$conq2;
	my $pop1=$killedpop{$rel}||0;
	my $pop2=$killedpop{$rrel}||0;
	my $n=$nsystems{$rel}||4;
	$a[0]=allianceid2tag($a[0]);
	$a[1]=allianceid2tag($a[1]);
	my $f=sprintf "%.4f",$relation{$rel}/$n-3-$conq/($n**0.25); # friendship rating
   my $allis="$a[0] -- $a[1]; //";
   while(length($allis)<16) {$allis.="/"}
	print "$allis $relation{$rel} $nsystems{$rel} $conq1 $conq2 $pop1 $pop2 $f\n";
}
