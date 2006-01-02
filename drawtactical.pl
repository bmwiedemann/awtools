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
use awdraw;
use mapcommon;
awinput_init();

our ($pixelpersystem, $mapsize, $mapxoff, $mapyoff);
our $imagesize=$mapsize*$pixelpersystem+1;
our $ih=$imagesize/2;
#my $file=shift(@ARGV) || die "need input\n";
#my $fileend=$file;
#$fileend=~s".*/"";
#$fileend=~s/(\d\d)-(\d\d)-(\d+)\.tar\.bz2/$3-$2-$1/;
my $out="datadir/tactical-$ENV{REMOTE_USER}";
my $c=25; # base color


#system(qw"tar xjf",$file);
#print "reading csv...\n";
#our @files=qw(starmap);

# Create the main image
#my $img = new GD::Image($imagesize, $imagesize);
#mapcoloralloc($img);
print "Drawing...\n";

sub drawaxis($) {my($img)=@_;
	$img->line(0,$ih, $imagesize,$ih,$mapcommon::axiscolor);
	$img->line($ih,0, $ih,$imagesize,$mapcommon::axiscolor);
}
my $img=awdraw::mapimage($mapxoff,$mapyoff, $mapxoff+$mapsize,$mapyoff+$mapsize, 1, \&drawaxis);
mapcommon::writeimg($img, "$out.png");
exit 0;

for(my $x=$mapxoff; $x-$mapxoff<$mapsize; $x++) {
  for(my $y=$mapyoff; $y-$mapyoff<$mapsize; $y++) {
	my ($px,$py)=awmap::maptoimg($x,$y);
	my $pxe=$px+$pixelpersystem;
	my $pye=$py+$pixelpersystem;
	my $v; # value
	my $color="white";
#	print "$x,$y $px,$py\n";

	# grid
	my $gridcolor=gridtest($x);
	$img->line($px,$py, $px,$pye, $gridcolor);
	$gridcolor=gridtest($y);
	$img->line($px,$py, $pxe,$py, $gridcolor);
	my @color;
#next;	
	if(defined($::starmap{"$x,$y"})) {
		my $id=$::starmap{"$x,$y"};
		my $sys=$::starmap{$id};
		$v=12;
		for(my $i=1; $i<=$v; $i++) {
			my $px2=$px+1;
			my $px3=$pxe-1;
			my $py2=$py+$i;
			my $planet=getplanet($id, $i); 
			my $ownerid=$$planet{ownerid};
			#print "own $ownerid\n";
			if(defined($ownerid) && $ownerid>2) {
				$color=mrelationcolorid($ownerid);
			} else {$color="white"}
			$img->line($px2,$py2, $px3,$py2, $::colorindex{$color});
			if(planet2siege($planet)) {
				$px2=$pxe-5;
				$img->line($px2,$py2, $px3,$py2, $::colorindex{"red"});
			}
		}
	}
	
}}


writeimg($img, "$out.png");
exit 0;

