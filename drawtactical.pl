#!/usr/bin/perl -w
#
# draw AW map
#
use GD;
use strict;

if(!$ENV{REMOTE_USER}) { $ENV{REMOTE_USER}="af"; }
our ($pixelpersystem, $mapsize, $mapxoff, $mapyoff);
require "awmap.pm";
require "mapcommon.pm";
our $imagesize=$mapsize*$pixelpersystem+1;
our $ih=$imagesize/2;
#my $file=shift(@ARGV) || die "need input\n";
#my $fileend=$file;
#$fileend=~s".*/"";
#$fileend=~s/(\d\d)-(\d\d)-(\d+)\.tar\.bz2/$3-$2-$1/;
my $out="tactical-$ENV{REMOTE_USER}";
my $c=25; # base color


#system(qw"tar xjf",$file);
#print "reading csv...\n";
#our @files=qw(starmap);
require "input.pm";

# Create the main image
my $img = new GD::Image($imagesize, $imagesize);
mapcoloralloc($img);
print "Drawing...\n";

sub pixel($$$) {my($x,$y,$c)=@_;
  $img->setPixel($x, $y, $c);
}
sub gridtest($) { $_[0]%10<=1 ? $::lightgridcolor:$::darkgridcolor }

{ my ($d1,$d2)=($::lightgridcolor,$::darkgridcolor);} #dummy statement to avoid warning

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

$img->line(0,$ih, $imagesize,$ih,$::axiscolor);
$img->line($ih,0, $ih,$imagesize,$::axiscolor);

for(my $x=$mapxoff; $x-$mapxoff<$mapsize; $x++) {
  for(my $y=$mapyoff; $y-$mapyoff<$mapsize; $y++) {
	my ($px,$py)=maptoimg($x,$y);
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
#		$v=($$sys{level}+1)/1.7;
#		if($v>12){$v=12}
#		my @player=@{$$sys{origin}};
#		foreach(@player) {
#			my @rel=getrelation($::player{$_}{name});
#			$color=getrelationcolor($rel[0]);
#			$color=~s/black/white/;
#			push(@color, $color);
#		}
#	}
	$v=12;
#	if($v) {
		for(my $i=1; $i<=$v; $i++) {
			my $px2=$px+1;
			my $px3=$pxe-1;
			my $py2=$py+$i;
#			if(@color) {
#				$color=$color[($i-1)/$v*@color];
#			}
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

