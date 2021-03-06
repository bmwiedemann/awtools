#!/usr/bin/perl -w
#
# draw AW map
#
BEGIN {if(!$ENV{REMOTE_USER}) { $ENV{REMOTE_USER}="idle"; }}

use GD;
use strict;
use awinput;
use awmap;
use mapcommon;
use awdraw;
awinput_init(1);

my $imagesize=$mapsize*$pixelpersystem+1;
my $ih=$imagesize/2;

print "Drawing $ENV{REMOTE_USER}...\n";

sub drawaxis($) {my($img)=@_;
	$img->line(0,$ih, $imagesize+$pixelpersystem,$ih,$mapcommon::axiscolor);
	$img->line($ih,0, $ih,$imagesize+$pixelpersystem,$mapcommon::axiscolor);
}
my $img=mapimage($mapxoff,$mapyoff, $mapxoff+$mapsize,$mapyoff+$mapsize, 1, \&drawaxis);

my $out="$awstandard::allidir/$ENV{REMOTE_USER}/tactical.png";
writeimg($img, $out);
awinput::awinput_finish();

