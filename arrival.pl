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

my $speed=1+0.16*$options{racespeed};
my $basetime=21.7+$options{planet}*3.2;

my $time=$basetime/$speed*0.9**$options{energy};
if($options{own}) {$time/=2}

my $h=int($time);
my $m=int(($time-$h)*60);
printf "%.3f = %2i:%.2i\n", $time, $h, $m;
