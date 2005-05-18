#!/usr/bin/perl -w
#
# draw AW map
#
use GD;
use strict;

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
sub mapimage($$$$) {
my ($mapxstart, $mapystart, $mapxend, $mapyend)=@_;
$mapxend++;
$mapyend++;
our $pixelpersystem=13;
my $mapsizex=$mapxend-$mapxstart;
my $mapsizey=$mapyend-$mapystart;
require "awmap.pm";
require "mapcommon.pm";
require "input.pm";
$::mapxoff=$mapxstart;
$::mapyoff=$mapystart;
$::mapxoff=$mapxstart; # dummy to avoid warning
$::mapyoff=$mapystart;
our $imagesizex=$mapsizex*$pixelpersystem+1;
our $imagesizey=$mapsizey*$pixelpersystem+1;



# Create the main image
my $img = new GD::Image($imagesizex, $imagesizey);
mapcoloralloc($img);

sub gridtest($) { $_[0]%10<=1 ? $::lightgridcolor:$::darkgridcolor }

{ my ($d1,$d2)=($::lightgridcolor,$::darkgridcolor);} #dummy statement to avoid warning


#$img->line(0,$ih, $imagesize,$ih,$::axiscolor);
#$img->line($ih,0, $ih,$imagesize,$::axiscolor);

 for(my $x=$mapxstart; $x<$mapxend; $x++) {
  for(my $y=$mapystart; $y<$mapyend; $y++) {
	my ($px,$py)=maptoimg($x,$y);
	my $pxe=$px+$pixelpersystem;
	my $pye=$py+$pixelpersystem;
	my $px2=$px+1;
	my $px3=$pxe-1;
	my $color;

	# grid
	my $gridcolor=gridtest($x);
	$img->line($px,$py, $px,$pye, $gridcolor);
	$gridcolor=gridtest($y);
	$img->line($px,$py, $pxe,$py, $gridcolor);

	if(defined($::starmap{"$x,$y"})) {
		my $id=$::starmap{"$x,$y"};
		my $sys=$::starmap{$id};
		for(my $i=1; $i<=12; $i++) {
			my $py2=$py+$i;
			my $planet=getplanet($id, $i); 
			my $ownerid=$$planet{ownerid};
			if(defined($ownerid) && $ownerid>2) {
				$color=mrelationcolorid($ownerid);
			} else {$color="white"}
			$img->rectangle($px2,$py2, $px3,$py2, $::colorindex{$color});
			if(planet2siege($planet)) {
				$img->rectangle($pxe-5,$py2, $px3,$py2, $::colorindex{"red"});
			}
		}
	}
	
 }}


 return $img->png();
}

1;
