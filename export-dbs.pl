#!/usr/bin/perl -w
use strict;
use awstandard;
use awinput;
use DBAccess;
use DBDump;

my $alli=$ENV{REMOTE_USER};
exit 0 unless $alli;

sub filter($) {
   $_[0]=~s/\r//g;
   $_[0]=~s/\n/\\n/g;
   $_[0]=~s/\t/\\t/g;
}

awinput_init(1);
# export relations DB
open(STDOUT, ">", "$awstandard::allidir/$alli/relation.csv");
my $relation=awinput::getallrelations();
foreach my $a (@$relation) {
   filter($a->[6]);
   print join("\t",@$a)."\n";
}

my $dbh=get_dbh;

open(STDOUT, ">", "$awstandard::allidir/$alli/fleets.csv");
dumptable("fleets", $alli, 1);
open(STDOUT, ">", "$awstandard::allidir/$alli/planetsplanning.csv");
dumptable("planetinfos", $alli, 2);
open(STDOUT, ">", "$awstandard::allidir/$alli/intelreport.csv");
dumptable("intelreport", $alli, 4);
open(STDOUT, ">", "$awstandard::allidir/$alli/internalintel.csv");
dumptable("internalintel", $alli, 32);
open(STDOUT, ">", "$awstandard::allidir/$alli/allirelations.csv");
dumptable("allirelations", $alli, 8);
open(STDOUT, ">", "$awstandard::allidir/$alli/relations.csv");
dumptable("relations", $alli, 8);


