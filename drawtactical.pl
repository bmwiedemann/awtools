#!/usr/bin/perl -w
#
# draw AW map
#
use Image::Magick;
use strict;

our ($pixelpersystem, $mapsize, $mapxoff, $mapyoff);
require "awmap.pm";
our $imagesize=$mapsize*$pixelpersystem+1;
our $ih=$imagesize/2;
#my $file=shift(@ARGV) || die "need input\n";
#my $fileend=$file;
#$fileend=~s".*/"";
#$fileend=~s/(\d\d)-(\d\d)-(\d+)\.tar\.bz2/$3-$2-$1/;
my $out="tactical";
my $axiscolor="blue";
my $c=25; # base color



#system(qw"tar xjf",$file);
print "reading csv...\n";
our @files=qw(starmap);
$ENV{REMOTE_USER}="af";
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
sub gridtest($) { $_[0]%10<=1 ? "lightgray":"gray" }


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
	my $gridcolor=gridtest($x);
	$img->Draw(fill=>'none',stroke=>$gridcolor,primitive=>'line', points=>"$px,$py $px,$pye",strokewidth=>1);
	$gridcolor=gridtest($y);
	$img->Draw(fill=>'none',stroke=>$gridcolor,primitive=>'line', points=>"$px,$py $pxe,$py",strokewidth=>1);
	my @color;
	
	if(defined($::starmap{"$x,$y"})) {
		my $id=$::starmap{"$x,$y"};
		my $sys=$::starmap{$id};
		$v=($$sys{level}+1)/1.7;
		if($v>12){$v=12}
		my @player=@{$$sys{origin}};
		foreach(@player) {
			my @rel=getrelation($::player{$_}{name});
			$color=getrelationcolor($rel[0]);
			$color=~s/black/white/;
			push(@color, $color);
		}
	}
	if($v) {
		for(my $i=1; $i<=$v; $i++) {
			my $px2=$px+1;
			my $px3=$pxe-1;
			my $py2=$py+$i;
			if(@color) {
				$color=$color[($i-1)/$v*@color];
			}
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

