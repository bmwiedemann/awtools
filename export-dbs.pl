#!/usr/bin/perl -w
use strict;
use awstandard;
use awinput;
use DBAccess2;

my $alli=$ENV{REMOTE_USER};
exit 0 unless $alli;

sub filter($) {
   $_[0]=~s/\r//g;
   $_[0]=~s/\n/\\n/g;
   $_[0]=~s/\t/\\t/g;
}

awinput_init();
# export relations DB
open(STDOUT, ">", "$awstandard::allidir/$alli/relation.csv");
while(my @a=each %relation) {
   filter($a[1]);
   print join("\t",@a)."\n";
}

open(STDOUT, ">", "$awstandard::allidir/$alli/planetsplanning.csv");
my $dbh=get_dbh;
my $r=$dbh->selectall_arrayref("SELECT * FROM `planetinfos` WHERE `alli`='$alli'");

foreach my $row($r) {
   filter($row->[8]); # info field
   print @$row,"\n";
}
#while(my @a=each %planetinfo) {
#   filter($a[1]);
#   print join("\t",@a)."\n";
#}

