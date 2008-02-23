#
# manage DB dumping from mysql
#
package DBDump;
use strict;
use warnings;
use DBAccess;
use awinput;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(dumptable);

sub textfilter($) {
   $_[0]=~s/\r//g;
   $_[0]=~s/\n/\\n/g;
   $_[0]=~s/\t/\\t/g;
}  

sub dumptable1($$@)
{ my($tname,$query, $vars)=@_;
   my $tabs=$dbh->selectall_arrayref("SHOW COLUMNS FROM `$tname`");
   my $sth=$dbh->prepare($query);
   my $r=$dbh->selectall_arrayref($sth,{},@$vars);

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
            textfilter($row->[$n]); # info field
         }
         if(!defined($row->[$n])) { $row->[$n]||=""; }
#         if($t->[1]=~m/int/) { $row->[$n]||=0; }
      }
#      $row->[5]||=0;
      print join("\t",@$row),"\n";
   }
}

sub dumptable($$$)
{ my($tname,$alli,$flag)=@_;
   my ($allimatch,$amvars)=awinput::get_alli_match2($alli,$flag);
   dumptable1($tname, "SELECT $tname.* FROM `$tname`,`toolsaccess` WHERE $allimatch", $amvars);
}

1;
