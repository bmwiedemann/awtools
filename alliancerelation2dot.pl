#!/usr/bin/perl -w
# this code is Copyright Bernhard M. Wiedemann and licensed under GNU GPL
use strict;
my $aentries=100;
my $eentries=85;
my @groups=(
#[qw{HNU HND GPS MAD}], 
#[qw{LA LD FO SP}],
#[qw{FUN STFU ION RATS DAT}],
#[qw{WAR WHS TPQ}],
#[qw{SSS XXX IB TGE}],
#[qw{SpIn DUDE}],
#[qw{FrS OINK wd}]
#[qw{NEMO OMEN}],
#[qw{THE NSA BKA PEYO}]
);
my $relre=qr!^([^ ]+) -- ([^ ;]+); // (\d+) (\d+) (\d+) (\d+) ([+-]?\d+)!;
my %group;
{
 my $n=0;
 foreach my $g (@groups) {
	foreach (@$g) {
		$group{$_}=$g;
	}
	unshift(@$g, ++$n);
 }
}

sub huefunc($) {my ($pop)=@_;
	my $green=0.3;
	my $red=1;
	my $enemybound=-3;
	my $friendbound=2;
	if($pop<$enemybound) {return $red}
	if($pop>$friendbound) {return $green}
	return ($red - (($pop-$enemybound)*($red-$green)/($friendbound-$enemybound))); # blue/purple
}
sub replacefunc($$$$) {my ($rel,$n,$conq1,$conq2)=@_;
	my $l="";
	my $fr=$n?$rel/$n:2; # average minimum pop
	my $min=0.1;
	if(!$n) {$n=1}
	my $c=($conq1+$conq2)/$n**0.25;
	$fr-=3+$c;
	my $saturation=(($n+$c)/13)*(1-$min)+$min;
	$saturation=($saturation>1)?1:($saturation<0?0:$saturation);
	my $col='"'.join(",",huefunc($fr),$saturation,1).'"';
	return qq! [color=$col$l];!;
}

print "graph alliances {\n";
open(F, "<", shift(@ARGV)) or die "error opening input file: $!";
my @edges;
{ local undef $/;
  my $edges=<F>;
  @edges=split("\n",$edges);
}
my %allis;
foreach(@edges) {
	next unless /^([^ ]+) -- ([^ ;]+)/;
	$allis{$1}++;
	$allis{$2}++;
}
sub max($$) {my($a,$b)=@_; $a|=0; $b|=0; return $a>$b?$a:$b}
sub sortfunc {
	return 0 unless $a=~/^([^ ]+) -- ([^ ;]+)/;
	my $max=max($allis{$1},$allis{$2});
	return 0 unless $b=~/^([^ ]+) -- ([^ ;]+)/;
	my $max2=max($allis{$1},$allis{$2});
	return $max2<=>$max;
}

sub sortfunc2 {
	my @a=split(" ",$a);
	my @b=split(" ",$b);
	return $a[8]<=>$b[8];
}
my @eedges=(sort sortfunc2 @edges)[0..$eentries-1];

my @newedges;
foreach(sort sortfunc (@edges[0..$aentries-1], @eedges)) {
	next unless m/$relre/;
	my ($a1,$a2,$rel,$n,$conq1,$conq2)=($1,$2,$3,$4,$5,$6);
	#s!; //(\d+) ([+-]?\d+)!replacefunc($1,$2)!e;
	for($a1,$a2) {
		if($group{$_}) 
			{$_=${$group{$_}}[0]}
			#{$_=join "_",@{$group{$_}}}
	}
	next if $a1 eq $a2;
	$_="$a1 -- $a2". replacefunc($rel,$n,$conq1,$conq2);
	push @newedges,$_;
}
#my $nodes=join " ",keys %allis;
print #"node [shape=plaintext,height=.1,width=0.1];".
join("\n",@newedges),"
//overlap=scale;
overlap=false;
splines=true;
//nodesep=.25;
//reanksep=1.0;
//epsilon=0.01;
}\n";
