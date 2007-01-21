# this module does no graphics itself, but delivers map data in a standardized format

package awmapfunc;
use strict;
use warnings;
use awstandard;
use awinput;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(&awplanfunc &awsiegefunc &awfilterchain);

my $s=12;

# all mapping functions:
# input: x,y coords
# input: systemID
# input: planetID
# output: array of [array width(pixels), color]

sub mrelationcolor($) { my($name)=@_;
	my @rel=getrelation($name);
	my $color=getrelationcolor($rel[0]);
	$color=~s/black/white/;
	return $color;
}
sub mrelationcolorid($) {
	mrelationcolor(playerid2name($_[0])); 
}
sub mrelationcolorid2($) {
	my($ownerid)=@_;
	my $color;
	if(defined($ownerid) && $ownerid>2) {
		$color=mrelationcolorid($ownerid);
	} else {$color=defined($ownerid)?"white":"dimgray"}
	return $color;
}

sub addleft
{
	my($v,$w,$c)=@_;
	$v->[0][0]-=$w;
	unshift(@$v, [$w,$c]);
}

sub addright(@$$)
{
	my($v,$w,$c)=@_;
	$v->[$#{$v}][0]-=$w;
	push(@$v, [$w,$c]);
}

sub addafter
{
	my($v,$i,$w,$c)=@_;
	$v->[0][$i]-=$w;
	splice(@$v, $i+1, 0, [$w,$c]);
}

# mapping functions:

sub awrelationfunc
{ my($x,$y,$sid,$pid)=@_;
	my $planet=getplanet($sid, $pid); 
	my $ownerid=$$planet{ownerid};
	my $color=mrelationcolorid2($ownerid);
	return [$s,$color];
}

sub awsiegefunc
{ my($x,$y,$sid,$pid,$data)=@_;
	my @v=awfilterchain($x,$y,$sid,$pid,$data);
	my $planet=getplanet($sid, $pid); 
	if(planet2siege($planet)) {
		addright(\@v, 3,"red");
	}
	return @v;
}

sub awplanfunc
{ my($x,$y,$sid,$pid,$data)=@_;
	my @v=awfilterchain($x,$y,$sid,$pid,$data);
	my @pinfo=getplanetinfo($sid, $pid);
	if(@pinfo) {
	   my $c=getstatuscolor($pinfo[0]);
		addright(\@v, 6, $c);
	}
	return @v;
}

sub awfilterchain
{ my($x,$y,$sid,$pid,$data)=@_;
	my @d=$data?@$data:(); # need to copy to not modify original data and allow use for later calls
	my $filt=pop(@d)||\&awrelationfunc; # base coloring as fallback
	return &$filt($x,$y,$sid,$pid,\@d);
}

1;
