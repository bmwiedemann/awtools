#!/usr/bin/perl -w
use strict;
sub replacefunc($$) {my ($rel,$n)=@_;
	my $l="";
#	if($in>100) {}#$l=qq!,label="$in"!}
#	else {$l=",color=gray"}
	my $f=int(sqrt($rel/6));
	my $fr=$rel/$n;
	my %hue=();
	for(0..9) {$hue{$_}=0.02}
	for(13..30) {$hue{$_}=0.3}
	for(10..12) {$hue{$_}=0.65}
	my $min=-0.1;
	my $saturation=($n/11)*(1-$min)+$min;
	$saturation=($saturation>1)?1:($saturation<0?0:$saturation);
	my $c='"'.join(",",$hue{int($fr)},$saturation,1).'"';
	return qq! [weight=$f,color=$c$l];!;
}

print "graph alliances {\n";
my $edges=`head -150 $ARGV[0]`;
my @edges=split("\n",$edges);
my %allis;
foreach(@edges) {
	next unless /^([^ ]+) -- ([^ ]+) /;
	$allis{$1}++;
	$allis{$2}++;
}
sub max($$) {return $_[0]>$_[1]?$_[0]:$_[1]}
sub sortfunc {
	return 0 unless $a=~/^([^ ]+) -- ([^ ]+) /;
	my $max=max($allis{$1},$allis{$2});
	return 0 unless $b=~/^([^ ]+) -- ([^ ]+) /;
	my $max2=max($allis{$1},$allis{$2});
	return $max2<=>$max;
}

my @newedges;
foreach(sort sortfunc @edges) {
	s!; //(\d+) ([+-]?\d+)!replacefunc($1,$2)!e;
	push @newedges,$_;
}
print join("\n",@newedges),"
//overlap=scale;
overlap=false;
splines=true;
//nodesep=.25;
//reanksep=1.0;
//epsilon=0.01;
}\n";
