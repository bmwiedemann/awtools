#!/usr/bin/perl -w

use strict;

# calculates and returns travel time for given options
sub traveltime { my ($options)=@_;
my $speed=1+0.16*$$options{racespeed};
#my ($c,$a)=(14.0,34.0);
#my ($c,$a)=(14.04,33.97);
#my ($c,$a)=(14.135,33.93);
my ($c,$a)=(14.248,33.88);
my $basetime=$c+sqrt(sqrt($$options{distance})+$$options{planet}*0.1)*$a;

my $time=$basetime/$speed*0.9**$$options{energy};
if($$options{own}) {$time/=2}

return $time;
}

1;
