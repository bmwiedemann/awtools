#!/usr/bin/perl -w
#
# draw AW map
#
use GD;
use strict;

if(!$ENV{REMOTE_USER}) { $ENV{REMOTE_USER}="af"; }
our ($pixelpersystem, $mapsize, $mapxoff, $mapyoff, $mapxend, $mapyend);
require "awmap.pm";
my $suf=".png";
my $scale=2;
my $extra=30;
$mapsize+=2*$extra;
$mapxoff-=$extra;
$mapxend=$mapsize+$mapxoff;
$mapyoff-=$extra;
$mapyend=$mapsize+$mapyoff;
$pixelpersystem*=$scale;
our $imagesize=$mapsize*$pixelpersystem+1;
our $ih=$imagesize/2;
if($ENV{REMOTE_USER} eq "af") {$mapxoff=-100}
#if($ENV{REMOTE_USER} eq "tgd") {$mapxoff=-110; $mapyoff=-100}
my $out="large-$ENV{REMOTE_USER}/star";
my $c=25; # base color

require "input.pm";
require "mapcommon.pm";

# Create the main image
my $im = new GD::Image($pixelpersystem, $pixelpersystem);
print "Drawing...\n";
mapcoloralloc($im);
my ($gc1,$gc2)=($::lightgridcolor, $::darkgridcolor); # grid color
($gc1,$gc2)=($::lightgridcolor, $::darkgridcolor); # avoid warning

sub drawgrid { my($c1,$c2,$im)=@_;
	$im->rectangle(0,0, $pixelpersystem,$scale-1, $c1);
	$im->rectangle(0,0, $scale-1,$pixelpersystem, $c2);
}

drawgrid($gc2,$gc2,$im);
writeimg($im, "$out-none0$suf");
drawgrid($gc1,$gc2,$im);
writeimg($im, "$out-none1$suf");
drawgrid($gc2,$gc1,$im);
writeimg($im, "$out-none2$suf");
drawgrid($gc1,$gc1,$im);
writeimg($im, "$out-none3$suf");

sub gridtest($$) { my($x,$y)=@_; my($c1,$c2)=($gc2,$gc2);
$y++; #FIXME: workaround for strange bug
if($x%10==0 || $y%10==0) {return ($gc1,$gc1)}
if($x%10<=1) {$c2=$gc1}
if($y%10<=1) {$c1=$gc1}
#print "($x,$y)=$c1, $c2\n";
return ($c1,$c2);
}
sub mrelationcolor($) { my($name)=@_;
	my @rel=getrelation($name);
	my $color=getrelationcolor($rel[0]);
	$color=~s/black/white/;
	return $color;
}
sub mrelationcolorid($) {
	my $e=$::player{$_[0]};
	my $dummye=$::player{$_[0]};
	my $n;
	if(!$e) {$n="unknown"}
	else {$n=$$e{name}}
	mrelationcolor($n); 
}


for(my $x=$mapxoff; $x<$mapxend; $x++) {
  for(my $y=$mapyoff; $y<$mapyend; $y++) {
	if(defined($::starmap{"$x,$y"})) {
		my ($px,$py)=(0,0);
		my $pxe=$px+$pixelpersystem;
		my $pye=$py+$pixelpersystem;
		my $v; # value
		my $color="white";
	#	print "$x,$y $px,$py\n";

		my $img=new GD::Image($pixelpersystem, $pixelpersystem);
		mapcoloralloc($img);

		# grid
		drawgrid(gridtest($x,$y),$img);
		my $id=$::starmap{"$x,$y"};
	   $v=12;
		for(my $i=1; $i<=$v; $i++) {
			my $statuscolor;
			my $px2=$px+$scale;
			my $px3=$pxe-1;
			my $py2=$py+$i*$scale;
			my @pinfo=getplanetinfo($id, $i);
			my $planet=getplanet($id, $i); 
			my $ownerid=$$planet{ownerid};
			#print "own $ownerid\n";
			if(defined($ownerid) && $ownerid>2) {
				$color=mrelationcolorid($ownerid);
			} else {$color="white"}
			if(@pinfo) {
				$statuscolor=getstatuscolor($pinfo[0]);
			} else {$statuscolor=undef}
			for my $j (0..$scale-1) {
				my $py3=$py2+$j;
				$img->line($px2,$py3, $px3,$py3, $::colorindex{$color});
				my $px5=$pxe+$scale-int($pixelpersystem/2);
				if($statuscolor) {
					$img->line($px5,$py3, $px3,$py3, $::colorindex{$statuscolor});
				}
				if(planet2siege($planet)) {
					my $px4=$pxe-3*$scale;
					$img->rectangle($px4,$py3, $px3,$py3+$scale-1, $::colorindex{red});
				}
			}
		}
		writeimg($img, "$out$x,$y$suf");
	}
}}

