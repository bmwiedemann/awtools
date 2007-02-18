#!/usr/bin/perl -w
use strict;
#use awstandard;
use awinput;

if($::options{url}=~/\?sid=(\d+)/) {
   my $sid=$1;
   my @c=systemid2coord($sid);
   if(!@c || !defined($c[0])) {
      print "NOTFOUND";
   } else {
      my @data;
      foreach my $n (1..12) {
         my $h=getplanet($sid,$n);
         if(!$h) {
            push(@data, "-1");
            next;
         }
         my $o=$$h{ownerid};
         my $aid=playerid2alliance($o);
         $aid||="0";
         push(@data, $aid);
      }
      push(@data, @c);
      print join " ",@data;
   }
}

1;
