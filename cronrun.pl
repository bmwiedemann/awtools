#!/usr/bin/perl -w
use strict;

chdir("/home/aw/inc");
for(<fiveminutely/*>) {
   next if /\/CVS$/;
#   print "running $_...\n";
	system($_);
}

