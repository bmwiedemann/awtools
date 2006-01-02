#!/usr/bin/perl -w

use strict;
use Getopt::Long;
#BEGIN {chdir "/home/bernhard/code/cvs/perl/awcalc";}
use arrival;

my %options=qw;
racespeed 0
energy 0
distance 0
planet 1
own 0
;;

my @options=qw"racespeed|r=i energy|e=i planet|p=i distance|d=i own|o";
GetOptions(\%options, @options);
my $time=arrival::traveltime(\%options);

my $h=int($time);
my $m=int(($time-$h)*60);
my $s=int((($time-$h)*60-$m)*60);
printf "%.3f = %2i:%.2i:%.2i\n", $time, $h, $m, $s;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time()+$time*3600);
$year+=1900;$mon++;
printf "ETA %.2i.%.2i.%i %2i:%.2i:%.2i\n", $mday,$mon,$year, $hour,$min,$sec;

