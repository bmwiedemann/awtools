#!/usr/bin/perl -w

use strict;
use Getopt::Long;

my %options=qw;
racespeed 0
energy 0
distance 0
planet 1
own 0
;;

my @options=qw"racespeed|r=i energy|e=i planet|p=i distance|d=i own|o";
GetOptions(\%options, @options);
my $path=".";
#require '$path/arrival.pm';

my @times=qw(13.94 24.60 28.69 32.70 35.62 38.24 40.44 42.59 44.53 46.46 47.54 49.56);
my $speed=1+0.16*$options{racespeed};
#my ($c,$a)=(14.0,34.0);
#my ($c,$a)=(14.04,33.97);
#my ($c,$a)=(14.135,33.93);
my ($c,$a)=(14.248,33.88);
my $basetime=$c+sqrt(sqrt($options{distance})+$options{planet}*0.1)*$a;
#my $basetime=$times[$options{planet}];

my $time=$basetime/$speed*0.9**$options{energy};
if($options{own}) {$time/=2}

my $h=int($time);
my $m=int(($time-$h)*60);
printf "%.3f = %2i:%.2i\n", $time, $h, $m;
