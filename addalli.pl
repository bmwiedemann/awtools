#!/usr/bin/perl -w
use strict;
use awinput;

my $tag=shift;
exit 1 if not $tag;

settoolsaccess($tag,$tag,255,255);

