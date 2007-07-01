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

my $dbh=get_dbh;
sub dumptable($$)
{ my($tname,$flag)=@_;
   my $tabs=$dbh->selectall_arrayref("SHOW COLUMNS FROM `$tname`");
   my ($allimatch,$amvars)=awinput::get_alli_match2($alli,$flag);
   my $sth=$dbh->prepare("SELECT $tname.* FROM `$tname`,`toolsaccess` WHERE $allimatch");
   my $r=$dbh->selectall_arrayref($sth,{},@$amvars);

   my @head=();
   foreach my $t (@$tabs) {
      push(@head, $t->[0]);
   }
   print join("\t",@head),"\n";
#   print "id\talli\tsidpid\tstatus\twho\tmodified_by\tmodified_at\tcreated_at\tinfo\n";
   foreach my $row(@$r) {
      for(my $n=$#{$tabs}; $n>=0; --$n) {
         my $t=$tabs->[$n];
         if($t->[1] eq "text" || $t->[1]=~/^varchar/) {
            filter($row->[$n]); # info field
         }
         if(!defined($row->[$n])) { $row->[$n]||=""; }
#         if($t->[1]=~m/int/) { $row->[$n]||=0; }
      }
#      $row->[5]||=0;
      print join("\t",@$row),"\n";
   }
}

open(STDOUT, ">", "$awstandard::allidir/$alli/fleets.csv");
dumptable("fleets", 1);
open(STDOUT, ">", "$awstandard::allidir/$alli/planetsplanning.csv");
dumptable("planetinfos", 2);
open(STDOUT, ">", "$awstandard::allidir/$alli/intelreport.csv");
dumptable("intelreport", 4);
open(STDOUT, ">", "$awstandard::allidir/$alli/internalintel.csv");
dumptable("internalintel", 32);


#while(my @a=each %planetinfo) {
#   filter($a[1]);
#   print join("\t",@a)."\n";
#}

