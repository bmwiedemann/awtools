#!/usr/bin/perl
use strict;
use warnings;

for(<fiveminutely/*>) {
   next if /\/CVS$/;
#   print "running $_...\n";
	system($_);
}

my ($sec,$min,$hour)=localtime();
if($min<5) {
   for(<hourly/*>) {
      next if /\/CVS$/;
#   print "running $_...\n";
      system($_);
   }
}
