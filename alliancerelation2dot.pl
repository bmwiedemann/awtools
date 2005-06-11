#!/usr/bin/perl -w
use strict;
my $entries=150;

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
	my $min=-0.1;
	$fr-=3+$conq1+$conq2;
	my $saturation=($n/11)*(1-$min)+$min;
	$saturation=($saturation>1)?1:($saturation<0?0:$saturation);
	my $c='"'.join(",",huefunc($fr),$saturation,1).'"';
	return qq! [color=$c$l];!;
}

print "graph alliances {\n";
my $edges=`head -$entries $ARGV[0]`;
my @edges=split("\n",$edges);
my %allis;
foreach(@edges) {
	next unless /^([^ ]+) -- ([^ ;]+)/;
	$allis{$1}++;
	$allis{$2}++;
}
sub max($$) {return $_[0]>$_[1]?$_[0]:$_[1]}
sub sortfunc {
	return 0 unless $a=~/^([^ ]+) -- ([^ ;]+)/;
	my $max=max($allis{$1},$allis{$2});
	return 0 unless $b=~/^([^ ]+) -- ([^ ;]+)/;
	my $max2=max($allis{$1},$allis{$2});
	return $max2<=>$max;
}

my @newedges;
foreach(sort sortfunc @edges) {
	next unless m!^([^ ]+) -- ([^ ;]+); // (\d+) (\d+) (\d+) (\d+) ([+-]?\d+)!;
	my ($a1,$a2,$rel,$n,$conq1,$conq2)=($1,$2,$3,$4,$5,$6);
	#s!; //(\d+) ([+-]?\d+)!replacefunc($1,$2)!e;
	$_="$a1 -- $a2". replacefunc($rel,$n,$conq1,$conq2);
	push @newedges,$_;
}
#my $nodes=join " ",keys %allis;
print join("\n",@newedges),"
//overlap=scale;
overlap=false;
splines=true;
//nodesep=.25;
//reanksep=1.0;
//epsilon=0.01;
}\n";
