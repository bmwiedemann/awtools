#!/usr/bin/perl -w
#
# draw AW map
#
BEGIN {if(!$ENV{REMOTE_USER}) { $ENV{REMOTE_USER}="idle"; }}
use GD;
use strict;
use awstandard;
use awinput;
use awmap;
use mapcommon;
use awmapfunc;
use awdraw2;

awinput_init(1);

my ($mapxend, $mapyend);

my $suf=".png";
my $scale=1;
my $extra=30;
$mapsize+=2*$extra;
$mapxoff-=$extra;
$mapxend=$mapsize+$mapxoff;
$mapyoff-=$extra;
$mapyend=$mapsize+$mapyoff;
my $pps=$pixelpersystem*$scale;
#if($ENV{REMOTE_USER} eq "af") {$mapxoff=-100}
#if($ENV{REMOTE_USER} eq "tgd") {$mapxoff=-110; $mapyoff=-100}
my $out="/home/aw/alli/$ENV{REMOTE_USER}/l/star";

print "Drawing $ENV{REMOTE_USER}...\n";

{
	my $img=new GD::Image($pps, $pps);
	mapcoloralloc($img);
	drawtile($img,-1,-1,0,0,$scale, sub{return ()});
	writeimg($img, "$out-none0$suf");
	drawtile($img,-1,1,0,0,$scale, sub{return ()});
	writeimg($img, "$out-none1$suf");
	drawtile($img,1,-1,0,0,$scale, sub{return ()});
	writeimg($img, "$out-none2$suf");
	drawtile($img,1,1,0,0,$scale, sub{return ()});
	writeimg($img, "$out-none3$suf");
}

for(my $x=$mapxoff; $x<$mapxend; $x++) {
  for(my $y=$mapyoff; $y<$mapyend; $y++) {
	my $id=systemcoord2id($x,$y);
	if(defined($id)) {
		my $img=new GD::Image($pps, $pps);
      mapcoloralloc($img);
		drawtile($img,$x,$y,0,0,$scale, \&awfilterchain, [\&awrelationfunc, \&awplanfunc, \&awsiegefunc]);
      writeimg($img, "$out$x,$y$suf");
	}
}}

