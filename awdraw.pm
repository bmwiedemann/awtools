#!/usr/bin/perl -w
#
# draw AW map
#
package awdraw;
use strict;
use GD;
use awmap;
use awstandard;
use awinput;
use mapcommon;

sub mrelationcolor($) { my($name)=@_;
	my @rel=getrelation($name);
	my $color=getrelationcolor($rel[0]);
	$color=~s/black/white/;
	return $color;
}
sub mrelationcolorid($) {
	mrelationcolor(playerid2name($_[0])); 
}
sub mapimage($$$$;$$) {
   my ($mapxstart, $mapystart, $mapxend, $mapyend, $scale, $initdraw)=@_;
   if(!$scale) {$scale=1}
   $mapxend++;
   $mapyend++;
   my $mapsizex=$mapxend-$mapxstart;
   my $mapsizey=$mapyend-$mapystart;
   $::mapxoff=$mapxstart;
   $::mapyoff=$mapystart;
   $::mapxoff=$mapxstart; # dummy to avoid warning
   $::mapyoff=$mapystart;
   our $imagesizex=$mapsizex*$::pixelpersystem+1;
   our $imagesizey=$mapsizey*$::pixelpersystem+1;



# Create the main image
   my $img = new GD::Image($imagesizex*$scale, $imagesizey*$scale);
   mapcommon::mapcoloralloc($img);

   sub gridtest($) { $_[0]%10<=1 ? $mapcommon::lightgridcolor:$mapcommon::darkgridcolor }

   { my ($d1,$d2)=($mapcommon::lightgridcolor,$mapcommon::darkgridcolor);} #dummy statement to avoid warning

   $initdraw && &$initdraw($img);
#$img->line(0,$ih, $imagesize,$ih,$::axiscolor);
#$img->line($ih,0, $ih,$imagesize,$::axiscolor);

    for(my $x=$mapxstart; $x<$mapxend; $x++) {
     for(my $y=$mapystart; $y<$mapyend; $y++) {
      my ($px,$py)=awmap::maptoimg($x,$y, $::mapxoff, $::mapyoff);
      my $pxe=$px+$::pixelpersystem;
      my $pye=$py+$::pixelpersystem;
      my $px2=$px+1;
      my $px3=$pxe-1;
      my $color;

      # grid
      my $gridcolor=gridtest($x);
      $img->filledRectangle($px*$scale,$py*$scale, ($px+1)*$scale-1,($pye+1)*$scale-1, $gridcolor);
      $gridcolor=gridtest($y);
      $img->filledRectangle($px*$scale,$py*$scale, ($pxe+1)*$scale-1,($py+1)*$scale-1, $gridcolor);
      my $id=systemcoord2id($x,$y);
      if(defined($id)) {
         for(my $i=1; $i<=12; $i++) {
            my $py2=$py+$i;
            my $planet=getplanet($id, $i); 
            my $ownerid=$$planet{ownerid};
            if(defined($ownerid) && $ownerid>2) {
               $color=mrelationcolorid($ownerid);
            } else {$color="white"}
            $img->filledRectangle($px2*$scale,$py2*$scale, ($px3+1)*$scale-1,($py2+1)*$scale-1, $mapcommon::colorindex{$color});
            if(planet2siege($planet)) {
               $img->filledRectangle(($pxe-5)*$scale,$py2*$scale, ($px3+1)*$scale-1,($py2+1)*$scale-1, $mapcommon::colorindex{"red"});
            }
         }
      }
     }
    }
    return $img;
}

1;
