#!/usr/bin/perl -w
#
# draw AW map
#
use Image::Magick;
use strict;

my $imagesize=190;
my $ih=$imagesize/2;
my $file=shift(@ARGV) || die "need input\n";
my $fileend=$file;
$fileend=~s".*/"";
$fileend=~s/(\d\d)-(\d\d)-(\d+)\.tar\.bz2/$3-$2-$1/;
my $out="out/$fileend";
my $axiscolor="blue";
my $c=25; # base color

sub maptoimg($$) { my($x,$y)=@_;
 return ($x+$ih,$y+$ih);}
sub imgtomap($$) { my($x,$y)=@_;
 return ($x-$ih,$y-$ih);}


system(qw"tar xjf",$file);
print "reading csv...\n";
require "input.pm";

#open(IN, "< $file") or die $!;
#my @coor=();
#while(<IN>) {
#	s/#.*//;
#	if(/^\s*$/){next}
#	my @a=split(" ");
#	push(@coor, [@a[0,1]]);
#}

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


for(my $px=0; $px<$imagesize; $px++) {
 for(my $py=0; $py<$imagesize; $py++) {
	my ($x,$y)=imgtomap($px,$py);
	my $v=0; # color value
	if(defined($::starmap{"$x,$y"})) {
		$v=$::starmap{$::starmap{"$x,$y"}}{"level"}/3;
	}
	if($v>0){$v=$c+$v*int((255-$c)/8)}
	if($v>255){$v=255}
#	print $v," ";
	if($v>0){
		$v=sprintf("#%.2x%.2x%.2x", $v,$v,$v);
		pixel($px,$py,$v);
	}
}}
#foreach(@coor){
#	my ($kx,$ky)=@$_;
#	my ($px,$py)=maptoimg($kx,$ky);
#	pixel($px,$py,"green");
#}



$img->Write("$out.png");
#$img->Write('win:');

