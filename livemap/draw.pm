package livemap::draw;

use strict;
use warnings;
use awmap;
use mapcommon;
use awmapfunc;
use awdraw2;
use awinput;

# input x,y and options
# output 13x13 pixel image of system
sub draw($$$) { my($x,$y,$options)=@_;
   awinput_init(1);
   my $img = mapimage($x,$y,$x,$y,1,undef, \&awfilterchain, [\&awrelationfunc, \&awplanfunc, \&awsiegefunc]);
   awinput::awinput_finish();
   return $img->png;
}

1;
