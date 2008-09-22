# this file defines permissions for allis
# e.g. sharing of info in tools
package awaccess;
use strict;
use awstandard;
use DB_File;
use Fcntl qw(:flock O_RDONLY);
use DBAccess2;
require Exporter;
use vars qw(@ISA @EXPORT);

our (%read_access);

@ISA = qw(Exporter);
@EXPORT = qw(%read_access %remap_alli
      &getallowedallis &is_allowedalli
);

#$read_access{af}=["rats","trol"];
#$read_access{rats}=["af","trol"];
#$read_access{trol}=["af","rats"];
#$read_access{tgd}=[qw(af)];
our %remap_planning=(
#      rats=>"af",
#      trol=>"af",
#      en=>"xr",
      );
our %remap_relations=(
#      rats=>"af",
#      en=>"xr",
#      seux=>"niai",
      );
our %remap_alli=(
#		punx=>"tgt",
#      lbb=>"lba",
#      ice=>"fir",
#      sjma=>"sj",
#      punx=>"fury",
#      es=>"esb", zob=>"esb", vip=>"esb", qi=>"esb",
);

sub getallowedallis() {
   my $dbh=get_dbh;
   return $dbh->selectcol_arrayref("SELECT tag FROM `toolsaccess` WHERE `wbits` =255");
}

sub is_allowedalli($) {
   my($alli)=@_;
   my $dbh=get_dbh;
   my $sth=$dbh->prepare("SELECT tag FROM `toolsaccess` WHERE `wbits` =255 AND tag=? AND othertag=tag");
   my ($r)=$dbh->selectall_arrayref($sth,{}, $alli);
   if(!$r || !@$r) {
      return 0;
   }
   return 1;
}

1;
