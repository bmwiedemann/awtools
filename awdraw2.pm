#
# draw AW map with chainable functions
#
package awdraw2;
use strict;
use warnings;
use GD;
use awmap;
use mapcommon;
use awinput;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(&drawtile &mapimage);

sub gridtest2($$) { my($x,$y)=@_; my($c1,$c2)=($darkgridcolor,$darkgridcolor);
   if($x%10==0 || $y%10==0) {return ($lightgridcolor,$lightgridcolor)}
   if($x%10<=1) {$c2=$lightgridcolor}
   if($y%10<=1) {$c1=$lightgridcolor}
   return ($c1,$c2);
}

sub drawgrid($$$$$$)
{ my($img,$x,$y,$px,$py,$scale)=@_;
      my ($gridcolor1,$gridcolor2)=gridtest2($x,$y);
      $img->filledRectangle($px,$py, $px+$pixelpersystem*$scale-1,$py+$scale-1, $gridcolor1);
      $img->filledRectangle($px,$py, $px+$scale-1,$py+$pixelpersystem*$scale-1, $gridcolor2);
      if($gridcolor1==$lightgridcolor) {
         $img->filledRectangle($px*$scale,$py*$scale, $px+$scale-1, $py+$scale-1, $gridcolor1);
      }
}

sub drawtile($$$$$$&;$)
{
	my($img,$x,$y,$px,$py,$scale,$func,$funcdata)=@_;
	drawgrid($img,$x,$y,$px,$py,$scale);
	my $id=systemcoord2id($x,$y);
	if($id) {
		$py+=$scale; # skip border
		for(my $i=1; $i<=12; $i++,$py+=$scale) {
			my @vals=&$func($x,$y,$id,$i,$funcdata);
			my $px1=$px+$scale;
			foreach my $v (@vals) {
				my ($width,$partcolor)=@$v;
				my $c=$colorindex{$partcolor};
				if(!defined($c)){$c=$partcolor};
				$img->filledRectangle($px1,$py, $px1+$width*$scale-1,$py+$scale-1, $c);
				$px1+=$width*$scale;
			}
		}
	}
	return $img;
}


sub mapimage($$$$;$$&$) {
   my ($mapxstart, $mapystart, $mapxend, $mapyend, $scale, $initdraw, $func, $funcdata)=@_;
   if(!$scale) {$scale=1}
   $mapxend++;
   $mapyend++;
   my $mapsizex=$mapxend-$mapxstart;
   my $mapsizey=$mapyend-$mapystart;
   my $imagesizex=$mapsizex*$pixelpersystem;
   my $imagesizey=$mapsizey*$pixelpersystem;

# Create the main image
   my $truecolor=$mapsizex<3;
   my $img = new GD::Image($imagesizex*$scale, $imagesizey*$scale);
   mapcoloralloc($img);
   $initdraw && &$initdraw($img);
	
	# loop to draw all stars
   for(my $x=$mapxstart; $x<$mapxend; $x++) {
   	for(my $y=$mapystart; $y<$mapyend; $y++) {
      	my ($px,$py)=awmap::maptoimg($x,$y, $mapxstart, $mapystart);
			drawtile($img,$x,$y,$px*$scale,$py*$scale,$scale,\&$func,$funcdata);
		}
	}
 
	return $img;
}

1;
