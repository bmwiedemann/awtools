#!/usr/bin/perl
use strict;
use warnings;

for(<fiveminutely/*>) {
   next if /\/CVS$/;
#   print "running $_...\n";
	system($_);
}

