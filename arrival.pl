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
require "$path/arrival.pm";

my $time=traveltime(\%options);

my $h=int($time);
my $m=int(($time-$h)*60);
printf "%.3f = %2i:%.2i\n", $time, $h, $m;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time()+$time*3600);
$year+=1900;$mon++;
printf "ETA %.2i.%.2i.%i %2i:%.2i:%.2i\n", $mday,$mon,$year, $hour,$min,$sec;

