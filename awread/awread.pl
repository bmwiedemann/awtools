#!/usr/bin/perl

use strict;
use warnings;
use awread;

my $f=shift || "in/secure-158d7.png";

my $string=awread::read_awimg($f);
#print "found $string\n";
(my $realstring=$f)=~s/in\/secure-(.{$awread::totalchars}).*/$1/;
#print "real $realstring\n";
if($realstring ne $string) {
	print "not ";
}
print "OK\n";

#$f=~s/^in/ut/;
#$f=~s/\.png/.bmp/;
#$img->Write("o$f"); # make sure we dont accidentally overwrite our originals

