#!/usr/bin/perl -w
#
# draw AW map
#
use Image::Magick;
use strict;

my $pixelpersystem=13; # for 12 planet status lines
my $mapsize=11;
my $mapxoff=-int(($mapsize-1)/2);
my $mapyoff=-int(($mapsize-1)/2);
my $imagesize=$mapsize*$pixelpersystem+1;
my $ih=$imagesize/2;
#my $file=shift(@ARGV) || die "need input\n";
#my $fileend=$file;
#$fileend=~s".*/"";
#$fileend=~s/(\d\d)-(\d\d)-(\d+)\.tar\.bz2/$3-$2-$1/;
my $out="tactical";
my $axiscolor="blue";
my $gridcolor="gray";
my $c=25; # base color

sub maptoimg($$) { my($x,$y)=@_;
 return (($x-$mapxoff)*$pixelpersystem, ($y-$mapyoff)*$pixelpersystem);}
#sub imgtomap($$) { my($x,$y)=@_;
# return (($x-$ih)/$pixelpersystem, ($y-$ih)/$pixelpersystem);}


#system(qw"tar xjf",$file);
print "reading csv...\n";
our @files=qw(starmap);
require "input.pm";

# Create the main image
my $im = new Image::Magick;
$im->Set(size=>$imagesize . 'x' . $imagesize);
$im->Read('xc:black');
print "Drawing...\n";
my $img=$im->Clone();

sub pixel($$$) {my($x,$y,$c)=@_;
  $img->Set("pixel[$x,$y]", $c);
}


$img->Draw(fill=>'none',stroke=>$axiscolor,primitive=>'line', points=>"0,$ih $imagesize,$ih",strokewidth=>1);
$img->Draw(fill=>'none',stroke=>$axiscolor,primitive=>'line', points=>"$ih,0 $ih,$imagesize",strokewidth=>1);


for(my $x=$mapxoff; $x-$mapxoff<$mapsize; $x++) {
  for(my $y=$mapyoff; $y-$mapyoff<$mapsize; $y++) {
	my ($px,$py)=maptoimg($x,$y);
	my $pxe=$px+$pixelpersystem;
	my $pye=$py+$pixelpersystem;
	my $v; # value
	my $color="white";
#	print "$x,$y $px,$py\n";

	# grid
	$img->Draw(fill=>'none',stroke=>$gridcolor,primitive=>'line', points=>"$px,$py $px,$pye",strokewidth=>1);
	$img->Draw(fill=>'none',stroke=>$gridcolor,primitive=>'line', points=>"$px,$py $pxe,$py",strokewidth=>1);
	
	if(defined($::starmap{"$x,$y"})) {
		$v=($::starmap{$::starmap{"$x,$y"}}{"level"}+1)/1.7;
		if($v>12){$v=12}
	}
	if($v) {
		for(my $i=1; $i<=$v; $i++) {
			my $px2=$px+1;
			my $px3=$pxe-1;
			my $py2=$py+$i;
			$img->Draw(fill=>'none',stroke=>$color,primitive=>'line', points=>"$px2,$py2 $px3,$py2", strokewidth=>1);
		}
	}
#	if($v>0){$v=$c+$v*int((255-$c)/8)}
#	if($v>255){$v=255}
#	if($v>0){
#		$v=sprintf("#%.2x%.2x%.2x", $v,$v,$v);
#		pixel($px,$py,$v);
#	}
	
}}



$img->Write("$out.png");
#$img->Write('win:');

