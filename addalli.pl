#!/usr/bin/perl -w
use strict;
use awinput;

my $tag=shift;
exit 1 if not $tag;
my $flags=shift||0;

settoolsaccess($tag,$tag,255,255,$flags);

