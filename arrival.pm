#!/usr/bin/perl -w

use strict;

# calculates and returns travel time for given options
sub traveltime { my ($options)=@_;
   my ($c,$a,$p,$e,$rs)=(850/60, 34, 0.1, 91/100, 0.19);
   my $basetime=$c+sqrt(sqrt($$options{distance})+$$options{planet}*$p)*$a;
   my $time=$basetime/(1+$rs*$$options{racespeed}) *$e**$$options{energy};
   if($$options{own}) {$time/=2}
   return $time;
}

1;
