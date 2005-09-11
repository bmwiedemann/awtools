#!/usr/bin/perl -w

use strict;

# calculates and returns travel time for given options
sub traveltime { my ($options)=@_;
my $speed=1+0.19*$$options{racespeed};
my ($c,$a)=(850/60,34);
#my ($c,$a)=(14.04,33.97);
#my ($c,$a)=(14.135,33.93);
#my ($c,$a)=(14.248,34.13);
my $e=90/100; # was (89/99);
my $basetime=$c+sqrt(sqrt($$options{distance})+$$options{planet}*0.1)*$a;

my $time=$basetime/$speed*$e**$$options{energy};
if($$options{own}) {$time/=2}

return $time;
}

1;
