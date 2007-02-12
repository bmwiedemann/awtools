package livemap::draw;

use strict;
use warnings;
use awmap;
use mapcommon;
use awmapfunc;
use awdraw2;
use awinput;

my @drawfuncs=(
      \&awrelationfunc,
      \&awplanfunc,
      \&awsiegefunc,
      \&awfleetstatusfunc,
      \&awfleetownerrelationfunc,
      \&awpopulationfunc,
      );

# input x,y and options (e.g. [1,3,2] indexing elements from the function array)
# output 13x13 pixel image of system
sub draw($$$) { my($x,$y,$options)=@_;
   awinput_init(1);
   my $img = mapimage($x,$y,$x,$y,1,undef, \&awfilterchain, [@drawfuncs[@$options]]);
   awinput::awinput_finish();
   return $img->png;
}

1;
