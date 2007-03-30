#!/usr/bin/perl -w
package arrival;

use strict;

my ($c,$a,$p,$e,$rs)=(850/60, 34, 0.1, 91/100, 0.17);

# calculates and returns travel time for given options
sub traveltime { my ($options)=@_;
   my $basetime=$c+sqrt(sqrt($$options{distance})+$$options{planet}*$p)*$a;
   my $time=$basetime/(1+$rs*$$options{racespeed}) *$e**$$options{energy};
   if($$options{own}) {$time/=2}
   return $time;
}

# merge effects of speed-race and energy
sub effectiveenergy($$) { my($racespeed, $energy)=@_;
   return $energy - log(1+$rs*$racespeed)/log($e);
}

# calc square of distance. needs awinput
sub get_distsqr($$)
{ my($s1,$s2)=@_;
   my($x1,$y1)=awinput::systemid2coord($s1);
   my($x2,$y2)=awinput::systemid2coord($s2);
   return (($x1-$x2)**2+($y1-$y2)**2);
}

1;
