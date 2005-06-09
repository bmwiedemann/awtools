#!/usr/bin/perl -w
use strict;
sub replacefunc($$) {my ($rel,$friend)=@_;
	my $l="";
#	if($in>100) {}#$l=qq!,label="$in"!}
#	else {$l=",color=gray"}
	my $f=int(sqrt($rel/6));
	my $c='"'.join(",",($friend<2?0.02:0.3),($f/10)*0.8+0.2,1).'"';
	return qq! [weight=$f,color=$c$l];!;
}

print "graph alliances {\n";
my $edges=`head -200 alliancerelation-050609`;
$edges=~s!; //(\d+) ([+-]?\d+)!replacefunc($1,$2)!ge;
print "$edges
overlap=scale;
splines=true;
//nodesep=.25;
//reanksep=1.0;
//epsilon=0.01;
}\n";
