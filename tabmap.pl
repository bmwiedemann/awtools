#!/usr/bin/perl -w
#
# draw AW map
#
use Image::Magick;
use strict;

our ($pixelpersystem, $mapsize, $mapxoff, $mapyoff);
require "awmap.pm";
my $scale=2;
my $extra=1;
$mapxoff-=$extra;
$mapyoff-=$extra;
$mapsize+=2*$extra;
$pixelpersystem*=$scale;
our $imagesize=$mapsize*$pixelpersystem+1;
our $ih=$imagesize/2;
if(!$ENV{REMOTE_USER}) { $ENV{REMOTE_USER}="af"; }
my $out="large-$ENV{REMOTE_USER}/star";
my $axiscolor="blue";
my $c=25; # base color
my ($gc1,$gc2)=("white","gray"); # grid color

require "input.pm";

# Create the main image
my $im = new Image::Magick;
$im->Set(size=>$pixelpersystem . 'x' . $pixelpersystem);
$im->Read('xc:black');
print "Drawing...\n";

sub drawgrid { my($c1,$c2)=@_;
	$im->Draw(fill=>'none',stroke=>$c1,primitive=>'line', points=>"0,0 $pixelpersystem,0",strokewidth=>$scale);
	$im->Draw(fill=>'none',stroke=>$c2,primitive=>'line', points=>"0,0 0,$pixelpersystem",strokewidth=>$scale);
}

drawgrid($gc2,$gc2);
$im->Write("$out-none0.gif");
drawgrid($gc1,$gc2);
$im->Write("$out-none1.gif");
drawgrid($gc2,$gc1);
$im->Write("$out-none2.gif");
drawgrid($gc1,$gc1);
$im->Write("$out-none3.gif");

sub gridtest($$) { my($x,$y)=@_; my($c1,$c2)=($gc2,$gc2);
$y++; #FIXME: workaround for strange bug
if($x%10==0 || $y%10==0) {return ($gc1,$gc1)}
if($x%10<=1) {$c2=$gc1}
if($y%10<=1) {$c1=$gc1}
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


for(my $x=$mapxoff; $x-$mapxoff<$mapsize; $x++) {
  for(my $y=$mapyoff; $y-$mapyoff<$mapsize; $y++) {
	my ($px,$py)=(0,0);
	my $pxe=$px+$pixelpersystem;
	my $pye=$py+$pixelpersystem;
	my $v; # value
	my $color="white";
	my $star=0;
#	print "$x,$y $px,$py\n";

	my $img=$im->Clone();
	# grid
	drawgrid(gridtest($x,$y));
	
	if(defined($::starmap{"$x,$y"})) {
		my $id=$::starmap{"$x,$y"};
#		my $sys=$::starmap{$id};
#		$v=($$sys{level}+1)/1.7;
#		if($v>12){$v=12}
#		my @player=@{$$sys{origin}};
#		foreach(@player) {
#			my @rel=getrelation($::player{$_}{name});
#			$color=getrelationcolor($rel[0]);
#			$color=~s/black/white/;
#		}
		$star=1;
#	}
	$v=12;
#	if($v) {
		for(my $i=1; $i<=$v; $i++) {
			my $statuscolor;
			my $px2=$px+$scale;
			my $px3=$pxe-1;
			my $py2=$py+$i*$scale;
#			if(@color) {
#				$color=$color[($i-1)/$v*@color];
#			}
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
				$img->Draw(fill=>'none',stroke=>$color,primitive=>'line', points=>"$px2,$py3 $px3,$py3", strokewidth=>1);
				my $px5=$pxe+$scale-int($pixelpersystem/2);
				if($statuscolor) {
					$img->Draw(fill=>'none',stroke=>$statuscolor,primitive=>'line', points=>"$px5,$py3 $px3,$py3", strokewidth=>1);
				}
				if(planet2siege($planet)) {
					my $px4=$pxe-3*$scale;
					$img->Draw(fill=>'none',stroke=>'red',primitive=>'line', points=>"$px4,$py3 $px3,$py3", strokewidth=>1);
				}
			}
		}
	}
	if($star) {
		$img->Write("$out$x,$y.gif");
#		last;
	}
}}



#$img->Write('win:');

