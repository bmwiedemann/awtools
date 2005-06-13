#!/usr/bin/perl -w
use strict;
require "input.pm";

my %relation;
my %nsystems;
my %conq;

#print STDERR "importing old data...\n";
my @olddata;
for my $day (1..7) {
	my %oldday;
	my @t=localtime(time()-3600*24*$day);
	my ($d,$m,$y)=(sprintf("%.2i",$t[3]),sprintf("%.2i",$t[4]+1), $t[5]+1900);
	open(F, "tar -Oxjf www1.astrowars.com/export/history/all$d-$m-$y.tar.bz2 planets.csv |");
	my $dummy=<F>;
	while(<F>) {
		next if m/^\s*$/;
		my @a=split("\t");
		$oldday{"$a[0]#$a[1]"}=$a[4];
#		print "$a[0]#$a[1] $a[4]\n";
	}
	push @olddata, \%oldday;
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
	foreach my $oldowner (@olddata) {
		my $o2=$$oldowner{$sidpid};
		last unless $o2 && $o2>2;
		if($o2!=$o) {
			my $aid2=playerid2alliance($o2);
			last unless $aid2;
			my $rel="$aid,$aid2";
			$conq{$rel}++;
			$relation{$rel}+=0; # force entry
			$nsystems{$rel}+=0;
#print "$sidpid $aid2->$aid\n";
			last;
		}
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
	my $conq1=$conq{$rel}||0;
	my $conq2=$conq{"$a[1],$a[0]"}||0;
	my $conq=$conq1+$conq2;
	my $n=$nsystems{$rel}||4;
	$a[0]=allianceid2tag($a[0]);
	$a[1]=allianceid2tag($a[1]);
	my $f=sprintf "%.4f",$relation{$rel}/$n-3-$conq/($n**0.25); # friendship rating
	print "$a[0] -- $a[1]; // $relation{$rel} $nsystems{$rel} $conq1 $conq2 $f\n";
}
